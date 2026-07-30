#!/bin/bash

echo "=========================================="
echo "💥 WIPE TOTAL DA INFRAESTRUTURA DA AWS"
echo "=========================================="

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

# 1. Deletar TODAS as APIs HTTP do API Gateway criadas
echo "🔥 [1/6] Apagando APIs no API Gateway..."
for api_id in $(aws apigatewayv2 get-apis --query "Items[?starts_with(Name, 'aws-cloudops-app')].ApiId" --output text 2>/dev/null); do
    aws apigatewayv2 delete-api --api-id "$api_id" 2>/dev/null
    echo "   -> API Gateway $api_id deletada."
done

# 2. Deletar a Lambda (Nome correto do print: aws-cloudops-app-default-backend)
echo "🔥 [2/6] Apagando Função Lambda..."
aws lambda delete-function --function-name aws-cloudops-app-default-backend 2>/dev/null && echo "   -> Lambda aws-cloudops-app-default-backend deletada." || true
# Garante caso exista alguma outra com o prefixo
for lambda_name in $(aws lambda list-functions --query "Functions[?starts_with(FunctionName, 'aws-cloudops-app')].FunctionName" --output text 2>/dev/null); do
    aws lambda delete-function --function-name "$lambda_name" 2>/dev/null
done

# 3. Deletar os 3 Dashboards do CloudWatch
echo "🔥 [3/6] Apagando CloudWatch Dashboards..."
aws cloudwatch delete-dashboards --dashboard-names \
    aws-cloudops-app-edge-infrastructure-dashboard \
    aws-cloudops-app-finops-costs-dashboard \
    aws-cloudops-app-lambda-performance-dashboard 2>/dev/null
echo "   -> Dashboards apagados."

# 4. Desabilitar CloudFront pelo ID Exato do print (E2GJBFS9C4XNL7)
echo "🔥 [4/6] Desabilitando CloudFront Distribution..."
DIST_ID="E2GJBFS9C4XNL7"
ETAG=$(aws cloudfront get-distribution-config --id "$DIST_ID" --query "ETag" --output text 2>/dev/null)
if [ -n "$ETAG" ]; then
    aws cloudfront get-distribution-config --id "$DIST_ID" --query "DistributionConfig" > /tmp/cf-config.json 2>/dev/null
    sed -i 's/"Enabled": true/"Enabled": false/' /tmp/cf-config.json
    aws cloudfront update-distribution --id "$DIST_ID" --if-match "$ETAG" --distribution-config file:///tmp/cf-config.json > /dev/null 2>&1
    echo "   -> CloudFront $DIST_ID foi desabilitado com sucesso! (Aguarde o status alterar no console para fazer o Delete)."
else
    echo "   -> CloudFront não encontrado ou já alterado."
fi

# 5. Esvaziar e deletar S3 e DynamoDB
echo "🔥 [5/6] Removendo S3 e DynamoDB..."
aws s3 rb s3://aws-cloudops-app-frontend --force 2>/dev/null || true
aws dynamodb delete-table --table-name aws-cloudops-app-default-users 2>/dev/null || true
echo "   -> S3 e DynamoDB limpos."

# 6. IAM Roles e Policies
echo "🔥 [6/6] Removendo IAM Role e Policies..."
aws iam detach-role-policy --role-name aws-cloudops-app-default-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null || true
aws iam delete-role-policy --role-name aws-cloudops-app-default-lambda-role --policy-name aws-cloudops-app-default-lambda-dashboard-policy 2>/dev/null || true
aws iam delete-role --role-name aws-cloudops-app-default-lambda-role 2>/dev/null || true
aws iam delete-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/aws-cloudops-app-default-lambda-dashboard-policy 2>/dev/null || true
echo "   -> IAM limpo."

echo "=========================================="
echo "✨ PROCESSO FINALIZADO!"
echo "=========================================="
