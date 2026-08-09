import json
import boto3
import hashlib
import os
import datetime
from urllib.parse import parse_qs

def lambda_handler(event, context):
    # Log de diagnóstico para capturar exatamente o que chega do API Gateway
    print("EVENTO RECEBIDO:", json.dumps(event))

    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT,DELETE"
    }
    
    # Captura o método HTTP de forma robusta
    method = event.get('httpMethod', '') or event.get('requestContext', {}).get('http', {}).get('method', '')

    # RETORNO IMEDIATO PARA OPTIONS - Sem banco de dados, sem falhas, sem erro 500!
    if method == 'OPTIONS':
        return {
            "statusCode": 200,
            "headers": headers,
            "body": ""
        }

    try:
        dynamodb = boto3.resource('dynamodb')
        TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'CloudOpsUsers')
        table = dynamodb.Table(TABLE_NAME)

        path = event.get('path', '') or event.get('rawPath', '') or event.get('requestContext', {}).get('http', {}).get('path', '')
        
        raw_body = event.get('body', {})
        body = {}
        if raw_body:
            if isinstance(raw_body, str):
                try:
                    body = json.loads(raw_body)
                except json.JSONDecodeError:
                    parsed = parse_qs(raw_body)
                    body = {k: v[0] for k, v in parsed.items()}
            elif isinstance(raw_body, dict):
                body = raw_body

        username = body.get('email') or body.get('username') or body.get('user') or body.get('mail')
        password = body.get('password') or body.get('pass') or body.get('pwd') or body.get('senha')

        def hash_password(password_str):
            return hashlib.sha256(password_str.encode()).hexdigest()

        # ======== 1. ROTA DE CADASTRO ========
        if 'register' in path.lower() and method == 'POST':
            if not username or not password:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "E-mail e senha obrigatórios."})}
            
            response = table.get_item(Key={'username': username})
            if 'Item' in response:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "Usuário já cadastrado."})}
            
            table.put_item(Item={'username': username, 'password_hash': hash_password(password)})
            return {"statusCode": 201, "headers": headers, "body": json.dumps({"message": "Usuário cadastrado com sucesso!"})}

        # ======== 2. ROTA DE LOGIN ========
        if 'login' in path.lower() and method == 'POST':
            if not username or not password:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "E-mail e senha obrigatórios."})}
            
            response = table.get_item(Key={'username': username})
            if 'Item' not in response or response['Item'].get('password_hash') != hash_password(password):
                return {"statusCode": 401, "headers": headers, "body": json.dumps({"error": "Credenciais inválidas."})}
            
            return {"statusCode": 200, "headers": headers, "body": json.dumps({"token": "cloudops_secure_token_abc123", "username": username})}

        # ======== 3. NOVO MOTOR DE DESCOBERTA (RECURSOS) ========
        if 'resources' in path.lower() and method == 'GET':
            try:
                tagging_client = boto3.client('resourcegroupstaggingapi', region_name='us-east-1')
                
                # Procura por TUDO na AWS que tenha a Tag "CloudOps" igual a "true"
                response = tagging_client.get_resources(
                    TagFilters=[
                        {'Key': 'CloudOps', 'Values': ['true']}
                    ]
                )
                
                discovered_resources = []
                for resource in response.get('ResourceTagMappingList', []):
                    arn = resource.get('ResourceARN')
                    # Extrai o serviço do ARN (ex: sqs, s3, dynamodb, lambda)
                    service = arn.split(':')[2].upper() 
                    # Tenta pegar o nome final do recurso
                    resource_name = arn.split(':')[-1].split('/')[-1] 
                    
                    discovered_resources.append({
                        "arn": arn,
                        "service": service,
                        "name": resource_name
                    })
                    
                return {"statusCode": 200, "headers": headers, "body": json.dumps({"resources": discovered_resources})}
                
            except Exception as e:
                print(f"Erro no resource tagger: {e}")
                return {"statusCode": 500, "headers": headers, "body": json.dumps({"error": f"Erro ao buscar recursos: {str(e)}"})}

        # ======== 4. ROTA DE CUSTOS (FINOPS - MANTIDA INTACTA) ========
        if 'summary' in path.lower() and method == 'GET':
            current_cost = 1.78
            projection = 2.14
            
            try:
                ce = boto3.client('ce', region_name='us-east-1')
                today = datetime.date.today()
                start_date = today.replace(day=1).strftime('%Y-%m-%d')
                end_date = (today + datetime.timedelta(days=1)).strftime('%Y-%m-%d')
                
                cost_response = ce.get_cost_and_usage(
                    TimePeriod={'Start': start_date, 'End': end_date},
                    Granularity='MONTHLY',
                    Metrics=['UnblendedCost']
                )
                
                results = cost_response.get('ResultsByTime', [])
                if results:
                    amount = results[0].get('Total', {}).get('UnblendedCost', {}).get('Amount', '0')
                    val = float(amount)
                    if val > 0:
                        current_cost = round(val * 1.127, 2)
                        projection = round(current_cost * 1.2, 2)
            except Exception:
                pass

            summary_data = {
                "cost": {"current": current_cost, "projection": projection},
                "distribution": {
                    "Cost Explorer": 0.97,
                    "Secrets Manager": 0.37,
                    "ELB/ECS/RDS": 0.23,
                    "Taxes": 0.20
                },
                "last_update": datetime.datetime.utcnow().isoformat() + "Z"
            }
            return {"statusCode": 200, "headers": headers, "body": json.dumps(summary_data)}
        
        return {"statusCode": 404, "headers": headers, "body": json.dumps({"error": "Rota não encontrada", "path": path})}
        
    except Exception as e:
        return {"statusCode": 500, "headers": headers, "body": json.dumps({"error": str(e)})}