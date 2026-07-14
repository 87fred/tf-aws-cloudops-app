import boto3
import json
import os
from datetime import datetime

# Inicializa os clientes AWS
ec2 = boto3.client('ec2')
ecs = boto3.client('ecs')
rds = boto3.client('rds')
ce = boto3.client('ce')

# Inicializa o DynamoDB para persistência de usuários
dynamodb = boto3.resource('dynamodb')

# Captura o nome da tabela injetada por variável de ambiente no Lambda
# ATENÇÃO: Alterado de 'DYNAMODB_TABLE_NAME' para 'DYNAMODB_TABLE' para bater com o Terraform
TABLE_NAME = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(TABLE_NAME) if TABLE_NAME else None

def get_ec2_summary():
    try:
        instances = ec2.describe_instances()
        return sum(len(r['Instances']) for r in instances['Reservations'])
    except Exception:
        return 0

def get_ecs_summary():
    try:
        clusters = ecs.list_clusters()
        return len(clusters.get('clusterArns', []))
    except Exception:
        return 0

def get_rds_summary():
    try:
        dbs = rds.describe_db_instances()
        return len(dbs.get('DBInstances', []))
    except Exception:
        return 0

def get_cost_data():
    try:
        today = datetime.now().strftime('%Y-%m-%d')
        start_of_month = datetime.now().replace(day=1).strftime('%Y-%m-%d')
        
        response = ce.get_cost_and_usage(
            TimePeriod={'Start': start_of_month, 'End': today},
            Granularity='MONTHLY',
            Metrics=['UnblendedCost']
        )
        amount = response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount']
        return float(amount)
    except Exception:
        return 0.0

def build_response(status_code, body_data):
    """Auxiliar para gerar a resposta com cabeçalhos de CORS consistentes"""
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
            'Content-Type': 'application/json'
        },
        'body': json.dumps(body_data)
    }

def handler(event, context):
    try:
        # Extrai o caminho (path) e o método da requisição do API Gateway v2
        path = event.get('rawPath', event.get('path', '/'))
        method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
        
        # ----------------------------------------------------
        # ROTA: POST /register
        # ----------------------------------------------------
        if path == "/register" and method == "POST":
            if not table:
                return build_response(500, {"erro": "Tabela DynamoDB não configurada no Lambda."})
            
            body = json.loads(event.get('body', '{}'))
            username = body.get('username')
            password = body.get('password') # Nota: Em produção, aplique hash na senha!
            
            if not username or not password:
                return build_response(400, {"erro": "Username e senha são obrigatórios."})
            
            # Verifica se o usuário já existe no DynamoDB
            response = table.get_item(Key={'username': username})
            if 'Item' in response:
                return build_response(400, {"erro": "Usuário já cadastrado."})
            
            # Registra novo usuário
            table.put_item(Item={'username': username, 'password': password})
            return build_response(201, {"mensagem": "Cadastro realizado com sucesso!"})
            
        # ----------------------------------------------------
        # ROTA: POST /login
        # ----------------------------------------------------
        elif path == "/login" and method == "POST":
            if not table:
                return build_response(500, {"erro": "Tabela DynamoDB não configurada no Lambda."})
                
            body = json.loads(event.get('body', '{}'))
            username = body.get('username')
            password = body.get('password')
            
            if not username or not password:
                return build_response(400, {"erro": "Username e senha são obrigatórios."})
                
            # Busca usuário no DynamoDB
            response = table.get_item(Key={'username': username})
            user_data = response.get('Item')
            
            if not user_data or user_data.get('password') != password:
                return build_response(401, {"erro": "Credenciais inválidas. Usuário ou senha incorretos."})
            
            # Login bem-sucedido: retorna um token mockado
            return build_response(200, {
                "mensagem": "Login efetuado com sucesso!",
                "token_fake": f"token-valido-para-{username}"
            })

        # ----------------------------------------------------
        # ROTA DEFAULT (Dashboard / Obter Métricas da AWS)
        # ----------------------------------------------------
        else:
            data = {
                "summary": {
                    "ec2_count": get_ec2_summary(),
                    "ecs_count": get_ecs_summary(),
                    "rds_count": get_rds_summary(),
                    "current_month_cost": get_cost_data(),
                    "status": "Healthy",
                    "last_sync": datetime.now().isoformat()
                },
                "distribution": [
                    {"label": "EC2", "value": get_ec2_summary()},
                    {"label": "ECS", "value": get_ecs_summary()},
                    {"label": "RDS", "value": get_rds_summary()}
                ]
            }
            return build_response(200, data)
            
    except Exception as e:
        return build_response(500, {"error": str(e)})