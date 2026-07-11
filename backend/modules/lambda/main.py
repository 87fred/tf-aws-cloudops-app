import json

def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Olá, O backend Serverless está no Ar!')
    }