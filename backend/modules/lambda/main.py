import json
import boto3
import hashlib
import os
from urllib.parse import parse_qs

def lambda_handler(event, context):
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
        # Pega a tabela do DynamoDB através da variável de ambiente configurada no Terraform
        TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'CloudOpsUsers')
        table = dynamodb.Table(TABLE_NAME)

        path = event.get('path', '') or event.get('rawPath', '') or event.get('requestContext', {}).get('http', {}).get('path', '')
        
        # Leitura blindada do corpo da requisição (funciona para JSON e Form Data)
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

        # Mapeia variações de nomes de campos enviados pelo frontend com total segurança
        username = body.get('email') or body.get('username') or body.get('user') or body.get('mail')
        password = body.get('password') or body.get('pass') or body.get('pwd') or body.get('senha')

        def hash_password(password_str):
            return hashlib.sha256(password_str.encode()).hexdigest()

        if 'register' in path and method == 'POST':
            if not username or not password:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "E-mail e senha obrigatórios."})}
            
            # Utiliza 'username' para bater com a chave primária da tabela do DynamoDB
            response = table.get_item(Key={'username': username})
            if 'Item' in response:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "Usuário já cadastrado."})}
            
            table.put_item(Item={'username': username, 'password_hash': hash_password(password)})
            return {"statusCode": 201, "headers": headers, "body": json.dumps({"message": "Usuário cadastrado com sucesso!"})}

        if 'login' in path and method == 'POST':
            if not username or not password:
                return {"statusCode": 400, "headers": headers, "body": json.dumps({"error": "E-mail e senha obrigatórios."})}
            
            # Utiliza 'username' para consultar a tabela
            response = table.get_item(Key={'username': username})
            if 'Item' not in response or response['Item'].get('password_hash') != hash_password(password):
                return {"statusCode": 401, "headers": headers, "body": json.dumps({"error": "Credenciais inválidas."})}
            
            return {"statusCode": 200, "headers": headers, "body": json.dumps({"token": "cloudops_secure_token_abc123", "username": username})}

        if 'summary' in path and method == 'GET':
            summary_data = {
                "cost": {"current": 12.50, "projection": 45.00},
                "distribution": {"ec2": 2, "ecs": 1, "rds": 1},
                "last_update": "2026-07-27T10:00:00Z"
            }
            return {"statusCode": 200, "headers": headers, "body": json.dumps(summary_data)}
        
        return {"statusCode": 404, "headers": headers, "body": json.dumps({"error": "Rota não encontrada", "path": path})}
        
    except Exception as e:
        return {"statusCode": 500, "headers": headers, "body": json.dumps({"error": str(e)})}