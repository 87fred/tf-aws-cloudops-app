#!/bin/bash

echo "=========================================="
echo "🔍 AUDITORIA DE RECURSOS AWS (PROJECT: aws-cloudops-app)"
echo "=========================================="

# 1. CloudFront Distributions
echo -n "🌐 Módulo CloudFront: "
CF_COUNT=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, 'aws-cloudops-app') || contains(Comment, 'aws-cloudops-app')].Id" --output text 2>/dev/null)
if [ -z "$CF_COUNT" ] || [ "$CF_COUNT" = "None" ]; then
    echo "🟢 OK (Nenhuma distribuição encontrada)"
else
    echo "🔴 ATENÇÃO: Distribuição(ões) ainda encontrada(s): $CF_COUNT"
fi

# 2. CloudWatch Log Groups & Dashboards
echo -n "📊 Módulo CloudWatch (Dashboards): "
CW_DASH=$(aws cloudwatch list-dashboards --query "DashboardEntries[?starts_with(DashboardName, 'aws-cloudops-app')].DashboardName" --output text 2>/dev/null)
if [ -z "$CW_DASH" ] || [ "$CW_DASH" = "None" ]; then
    echo "🟢 OK (Nenhum dashboard encontrado)"
else
    echo "🔴 ATENÇÃO: Dashboard(s) encontrado(s): $CW_DASH"
fi

echo -n "🪵 Módulo CloudWatch (Log Groups): "
CW_LOGS=$(aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/aws-cloudops-app" --query "logGroups[].logGroupName" --output text 2>/dev/null)
if [ -z "$CW_LOGS" ] || [ "$CW_LOGS" = "None" ]; then
    echo "🟢 OK (Nenhum log group encontrado)"
else
    echo "🔴 ATENÇÃO: Log group(s) encontrado(s): $CW_LOGS"
fi

# 3. DynamoDB Tables
echo -n "🗄️  Módulo DynamoDB: "
DDB_COUNT=$(aws dynamodb list-tables --query "TableNames[?starts_with(@, 'aws-cloudops-app')]" --output text 2>/dev/null)
if [ -z "$DDB_COUNT" ] || [ "$DDB_COUNT" = "None" ]; then
    echo "🟢 OK (Nenhuma tabela encontrada)"
else
    echo "🔴 ATENÇÃO: Tabela(s) encontrada(s): $DDB_COUNT"
fi

# 4. IAM Roles & Policies
echo -n "🔑 Módulo IAM (Roles): "
IAM_ROLES=$(aws iam list-roles --query "Roles[?starts_with(RoleName, 'aws-cloudops-app')].RoleName" --output text 2>/dev/null)
if [ -z "$IAM_ROLES" ] || [ "$IAM_ROLES" = "None" ]; then
    echo "🟢 OK (Nenhuma Role encontrada)"
else
    echo "🔴 ATENÇÃO: Role(s) encontrada(s): $IAM_ROLES"
fi

echo -n "🔑 Módulo IAM (Policies): "
IAM_POLICIES=$(aws iam list-policies --scope Local --query "Policies[?starts_with(PolicyName, 'aws-cloudops-app')].PolicyName" --output text 2>/dev/null)
if [ -z "$IAM_POLICIES" ] || [ "$IAM_POLICIES" = "None" ]; then
    echo "🟢 OK (Nenhuma Policy customizada encontrada)"
else
    echo "🔴 ATENÇÃO: Policy(ies) encontrada(s): $IAM_POLICIES"
fi

# 5. Lambda Functions
echo -n "⚡ Módulo Lambda: "
LAMBDA_COUNT=$(aws lambda list-functions --query "Functions[?starts_with(FunctionName, 'aws-cloudops-app')].FunctionName" --output text 2>/dev/null)
if [ -z "$LAMBDA_COUNT" ] || [ "$LAMBDA_COUNT" = "None" ]; then
    echo "🟢 OK (Nenhuma função Lambda encontrada)"
else
    echo "🔴 ATENÇÃO: Função(ões) encontrada(s): $LAMBDA_COUNT"
fi

# 6. API Gateways (HTTP APIs)
echo -n "🚀 Módulo API Gateway: "
API_COUNT=$(aws apigatewayv2 get-apis --query "Items[?starts_with(Name, 'aws-cloudops-app')].Name" --output text 2>/dev/null)
if [ -z "$API_COUNT" ] || [ "$API_COUNT" = "None" ]; then
    echo "🟢 OK (Nenhuma API Gateway encontrada)"
else
    echo "🔴 ATENÇÃO: API(s) encontrada(s): $API_COUNT"
fi

# 7. S3 Buckets
echo -n "🪣 Módulo S3: "
S3_COUNT=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'aws-cloudops-app')].Name" --output text 2>/dev/null)
if [ -z "$S3_COUNT" ] || [ "$S3_COUNT" = "None" ]; then
    echo "🟢 OK (Nenhum bucket encontrado)"
else
    echo "🔴 ATENÇÃO: Bucket(s) encontrado(s): $S3_COUNT"
fi

echo "=========================================="
echo "✨ CHECKLIST FINALIZADO"
echo "=========================================="
