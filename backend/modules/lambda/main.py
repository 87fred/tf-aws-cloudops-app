import json
import os
import boto3

# Inicializa o cliente do DynamoDB fora do handler para melhor performance 
# Buscamos o nome da tabela direto de uma variável de ambiente que o Terraform injetará no Lambda
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE", "aws-cloudops-app-dev-users")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DYNAMODB_TABLE)

def handler(event, context):
    # Log simples para te ajudar a debugar o que está chegando do API Gateway
    print("Evento recebido:", json.dumps(event))
    
    path = event.get("path", "")
    http_method = event.get("httpMethod", "")
    
    # Configuração de CORS para que o seu futuro Frontend consiga conversar com essa API sem bloqueios
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
        "Access-Control-Allow-Headers": "Content-Type"
    }

    try:
        # Se for uma requisição OPTIONS (CORS preflight enviado pelo navegador), apenas responde Ok
        if http_method == "OPTIONS":
            return {"statusCode": 200, "headers": headers, "body": ""}

        # ----------------------------------------------------
        # ROTA DE CADASTRO: POST /register
        # ----------------------------------------------------
        if path == "/register" and http_method == "POST":
            body = json.loads(event.get("body", "{}"))
            username = body.get("username")
            password = body.get("password")

            if not username or not password:
                return {
                    "statusCode": 400,
                    "headers": headers,
                    "body": json.dumps({"erro": "E-mail e senha são obrigatórios."})
                }

            # Salva o usuário no DynamoDB
            table.put_item(
                Item={
                    "username": username,
                    "password_hash": password 
                }
            )

            return {
                "statusCode": 201,
                "headers": headers,
                "body": json.dumps({"mensagem": f"Usuário {username} cadastrado com sucesso!"})
            }

        # ----------------------------------------------------
        # ROTA DE LOGIN: POST /login
        # ----------------------------------------------------
        elif path == "/login" and http_method == "POST":
            body = json.loads(event.get("body", "{}"))
            username = body.get("username")
            password_input = body.get("password")

            if not username or not password_input:
                return {
                    "statusCode": 400,
                    "headers": headers,
                    "body": json.dumps({"erro": "E-mail e senha são obrigatórios."})
                }

            # Busca o usuário na tabela usando a Chave Primária (username)
            response = table.get_item(Key={"username": username})
            user_entry = response.get("Item")

            # Valida se o usuário existe e se a senha bate
            if not user_entry or user_entry.get("password_hash") != password_input:
                return {
                    "statusCode": 401,
                    "headers": headers,
                    "body": json.dumps({"erro": "Credenciais inválidas."})
                }

            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({
                    "mensagem": "Login efetuado com sucesso!",
                    "token_fake": "token-jwt-simulado-aqui"
                })
            }

        # Rota não encontrada
        return {
            "statusCode": 404,
            "headers": headers,
            "body": json.dumps({"erro": "Rota não encontrada."})
        }

    except Exception as e:
        print(f"Erro interno: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"erro": "Erro interno no servidor."})
        }