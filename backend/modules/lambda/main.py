import json

def handler(event, context):
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json' # Isso ajuda o curl/jq a formatar melhor
        },
        'body': json.dumps({
            'mensagem': 'Olá, o backend Serverless está no Ar!',
            'status': 'sucesso'
        })
    }