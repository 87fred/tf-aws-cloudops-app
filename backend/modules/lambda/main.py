import boto3
import json
import os
from datetime import datetime

# Inicializa os clientes AWS
ec2 = boto3.client('ec2')
ecs = boto3.client('ecs')
rds = boto3.client('rds')
ce = boto3.client('ce')
dynamodb = boto3.resource('dynamodb')

# Tabela do DynamoDB
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
        today = datetime.now()
        today_str = today.strftime('%Y-%m-%d')
        start_of_month = today.replace(day=1).strftime('%Y-%m-%d')
        
        response = ce.get_cost_and_usage(
            TimePeriod={'Start': start_of_month, 'End': today_str},
            Granularity='MONTHLY',
            Metrics=['UnblendedCost']
        )
        amount = float(response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount'])
        
        # Cálculo da projeção baseada na média diária
        dias_passados = today.day
        dias_no_mes = 31 
        projeção = (amount / dias_passados) * dias_no_mes
        
        return {"current": amount, "projection": projeção}
    except Exception:
        return {"current": 0.0, "projection": 0.0}

def build_response(status_code, body_data):
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
        raw_path = event.get('rawPath', event.get('path', '/'))
        path = "/" + raw_path.strip("/")
        method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
        
        if not event.get('rawPath'): 
            method = event.get('httpMethod', method)

        # ROTA: POST /register
        if path.endswith("/register") and method == "POST":
            body = json.loads(event.get('body', '{}'))
            if not body.get('username') or not body.get('password'):
                return build_response(400, {"erro": "Username e senha são obrigatórios."})
            
            if 'Item' in table.get_item(Key={'username': body.get('username')}):
                return build_response(400, {"erro": "Usuário já cadastrado."})
            
            table.put_item(Item={'username': body.get('username'), 'password': body.get('password')})
            return build_response(201, {"mensagem": "Cadastro realizado!"})
            
        # ROTA: POST /login
        elif path.endswith("/login") and method == "POST":
            body = json.loads(event.get('body', '{}'))
            user = table.get_item(Key={'username': body.get('username')}).get('Item')
            if not user or user.get('password') != body.get('password'):
                return build_response(401, {"erro": "Credenciais inválidas."})
            return build_response(200, {"token": f"token-valido-para-{body.get('username')}"})

        # ROTA: GET /api/summary
        elif path.endswith("/api/summary") and method == "GET":
            data = {
                "health": {
                    "overall": "98%",
                    "cpu_avg": "34%",
                    "mem_avg": "52%",
                    "availability": "99.99%"
                },
                "distribution": {
                    "ec2": get_ec2_summary(),
                    "ecs": get_ecs_summary(),
                    "rds": get_rds_summary()
                },
                "cost": get_cost_data(),
                "last_update": datetime.now().isoformat()
            }
            return build_response(200, data)

        # ROTA DEFAULT
        else:
            return build_response(200, {"status": "API Online", "version": "1.0"})
            
    except Exception as e:
        return build_response(500, {"error": str(e)})