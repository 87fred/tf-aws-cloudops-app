#!/bin/bash

echo "=================================================="
echo "💥 WIPE TOTAL AUTOMÁTICO DE RECURSOS + CHECKLIST"
echo "=================================================="

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
echo "📍 Account ID: ${ACCOUNT_ID:-'Não identificado'}"
echo "--------------------------------------------------"

# 1. CloudFront (Desativa todas as distribuições associadas sem erros de S3/OAC)
echo "🔥 [1/8] Desabilitando Distribuições CloudFront..."
DIST_IDS=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, 'aws-cloudops-app') || contains(Comment, 'aws-cloudops-app')].Id" --output text 2>/dev/null)

for dist_id in $DIST_IDS; do
    ETAG=$(aws cloudfront get-distribution-config --id "$dist_id" --query "ETag" --output text 2>/dev/null)
    if [ -n "$ETAG" ]; then
        aws cloudfront get-distribution-config --id "$dist_id" --query "DistributionConfig" 2>/dev/null | \
        python3 -c '
import sys, json
d = json.load(sys.stdin)
d["Enabled"] = False
if "Origins" in d and "Items" in d["Origins"] and len(d["Origins"]["Items"]) > 0:
    origin = d["Origins"]["Items"][0]
    origin["DomainName"] = "example.com"
    origin["CustomOriginConfig"] = {
        "HTTPPort": 80, "HTTPSPort": 443, "OriginProtocolPolicy": "http-only",
        "OriginSslProtocols": {"Quantity": 1, "Items": ["TLSv1.2"]},
        "OriginReadTimeout": 30, "OriginKeepaliveTimeout": 5
    }
    if "S3OriginConfig" in origin: del origin["S3OriginConfig"]
    if "OriginAccessControlId" in origin: origin["OriginAccessControlId"] = ""
print(json.dumps(d))
' > /tmp/cf-clean.json
        aws cloudfront update-distribution --id "$dist_id" --if-match "$ETAG" --distribution-config file:///tmp/cf-clean.json > /dev/null 2>&1
        echo "   -> CloudFront $dist_id preparado para desligamento!"
    fi
done

# 2. CloudFront OACs (Origin Access Controls)
echo "🔥 [2/8] Apagando CloudFront OACs..."
for oac_id in $(aws cloudfront list-origin-access-controls --query "OriginAccessControlList.Items[?contains(Name, 'aws-cloudops-app')].Id" --output text 2>/dev/null); do
    OAC_ETAG=$(aws cloudfront get-origin-access-control --id "$oac_id" --query "ETag" --output text 2>/dev/null)
    aws cloudfront delete-origin-access-control --id "$oac_id" --if-match "$OAC_ETAG" 2>/dev/null
    echo "   -> OAC $oac_id deletado."
done

# 3. API Gateway (HTTP APIs & Stages)
echo "🔥 [3/8] Apagando API Gateways..."
for api_id in $(aws apigatewayv2 get-apis --query "Items[?starts_with(Name, 'aws-cloudops-app')].ApiId" --output text 2>/dev/null); do
    aws apigatewayv2 delete-api --api-id "$api_id" 2>/dev/null
    echo "   -> API Gateway $api_id deletada."
done

# 4. AWS Lambda Functions
echo "🔥 [4/8] Apagando Funções Lambda..."
for lambda_name in $(aws lambda list-functions --query "Functions[?starts_with(FunctionName, 'aws-cloudops-app')].FunctionName" --output text 2>/dev/null); do
    aws lambda delete-function --function-name "$lambda_name" 2>/dev/null
    echo "   -> Lambda $lambda_name deletada."
done

# 5. CloudWatch (Log Groups, Dashboards & Alarmes)
echo "🔥 [5/8] Limpando CloudWatch (Log Groups, Dashboards e Alarmes)..."
for lg in $(aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/aws-cloudops-app" --query "logGroups[].logGroupName" --output text 2>/dev/null); do
    aws logs delete-log-group --log-group-name "$lg" 2>/dev/null
    echo "   -> Log Group $lg deletado."
done

# Busca inteligente de alarmes (com ou sem / no inicio)
for alarm in $(aws cloudwatch describe-alarms --query "MetricAlarms[?contains(AlarmName, 'aws-cloudops-app')].AlarmName" --output text 2>/dev/null); do
    aws cloudwatch delete-alarms --alarm-names "$alarm" 2>/dev/null
    echo "   -> Alarme $alarm deletado."
done

for dash in $(aws cloudwatch list-dashboards --query "DashboardEntries[?starts_with(DashboardName, 'aws-cloudops-app')].DashboardName" --output text 2>/dev/null); do
    aws cloudwatch delete-dashboards --dashboard-names "$dash" 2>/dev/null
    echo "   -> Dashboard $dash deletado."
done

# 6. DynamoDB Tables
echo "🔥 [6/8] Removendo Tabelas DynamoDB..."
for table in $(aws dynamodb list-tables --query "TableNames[?starts_with(@, 'aws-cloudops-app')]" --output text 2>/dev/null); do
    aws dynamodb delete-table --table-name "$table" 2>/dev/null
    echo "   -> Tabela DynamoDB $table deletada."
done

# 7. S3 Buckets
echo "🔥 [7/8] Esvaziando e removendo S3 Buckets..."
for bucket in $(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'aws-cloudops-app')].Name" --output text 2>/dev/null); do
    aws s3 rb "s3://$bucket" --force 2>/dev/null
    echo "   -> Bucket S3 $bucket deletado."
done

# 8. IAM Roles & Policies
echo "🔥 [8/8] Desanexando e Removendo IAM Roles e Policies..."
for role_name in $(aws iam list-roles --query "Roles[?starts_with(RoleName, 'aws-cloudops-app')].RoleName" --output text 2>/dev/null); do
    for policy_arn in $(aws iam list-attached-role-policies --role-name "$role_name" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null); do
        aws iam detach-role-policy --role-name "$role_name" --policy-arn "$policy_arn" 2>/dev/null
    done
    for inline_policy in $(aws iam list-role-policies --role-name "$role_name" --query "PolicyNames[]" --output text 2>/dev/null); do
        aws iam delete-role-policy --role-name "$role_name" --policy-name "$inline_policy" 2>/dev/null
    done
    aws iam delete-role --role-name "$role_name" 2>/dev/null
    echo "   -> IAM Role $role_name removida."
done

for policy_arn in $(aws iam list-policies --scope Local --query "Policies[?starts_with(PolicyName, 'aws-cloudops-app')].Arn" --output text 2>/dev/null); do
    aws iam delete-policy --policy-arn "$policy_arn" 2>/dev/null
    echo "   -> IAM Policy $policy_arn removida."
done

# Aguardo dinâmico para Exclusão do CloudFront
if [ -n "$DIST_IDS" ] && [ "$DIST_IDS" != "None" ]; then
    echo "--------------------------------------------------"
    echo "⏳ Aguardando liberação do CloudFront para exclusão..."
    for dist_id in $DIST_IDS; do
        while true; do
            STATUS=$(aws cloudfront get-distribution --id "$dist_id" --query "Distribution.Status" --output text 2>/dev/null || echo "Deleted")
            if [ "$STATUS" = "Deployed" ]; then
                NEW_ETAG=$(aws cloudfront get-distribution-config --id "$dist_id" --query "ETag" --output text 2>/dev/null)
                aws cloudfront delete-distribution --id "$dist_id" --if-match "$NEW_ETAG" 2>/dev/null
                echo "💥 CloudFront $dist_id DELETADO DEFINITIVAMENTE!"
                break
            elif [ "$STATUS" = "Deleted" ]; then
                break
            fi
            echo "   Aguardando CloudFront ($dist_id) terminar alteração (Status: $STATUS)..."
            sleep 15
        done
    done
fi

echo ""
echo "=================================================="
echo "🔍 CHECKLIST E AUDITORIA AUTOMÁTICA DE INFRAESTRUTURA"
echo "=================================================="

echo -n "🌐 Módulo CloudFront: "
CF_COUNT=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].DomainName, 'aws-cloudops-app') || contains(Comment, 'aws-cloudops-app')].Id" --output text 2>/dev/null)
if [ -z "$CF_COUNT" ] || [ "$CF_COUNT" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $CF_COUNT"; fi

echo -n "📊 Módulo CloudWatch (Dashboards): "
CW_DASH=$(aws cloudwatch list-dashboards --query "DashboardEntries[?starts_with(DashboardName, 'aws-cloudops-app')].DashboardName" --output text 2>/dev/null)
if [ -z "$CW_DASH" ] || [ "$CW_DASH" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $CW_DASH"; fi

echo -n "🪵 Módulo CloudWatch (Log Groups): "
CW_LOGS=$(aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/aws-cloudops-app" --query "logGroups[].logGroupName" --output text 2>/dev/null)
if [ -z "$CW_LOGS" ] || [ "$CW_LOGS" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $CW_LOGS"; fi

echo -n "🚨 Módulo CloudWatch (Alarmes): "
CW_ALARMS=$(aws cloudwatch describe-alarms --query "MetricAlarms[?contains(AlarmName, 'aws-cloudops-app')].AlarmName" --output text 2>/dev/null)
if [ -z "$CW_ALARMS" ] || [ "$CW_ALARMS" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $CW_ALARMS"; fi

echo -n "🗄️  Módulo DynamoDB: "
DDB_COUNT=$(aws dynamodb list-tables --query "TableNames[?starts_with(@, 'aws-cloudops-app')]" --output text 2>/dev/null)
if [ -z "$DDB_COUNT" ] || [ "$DDB_COUNT" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $DDB_COUNT"; fi

echo -n "🔑 Módulo IAM (Roles): "
IAM_ROLES=$(aws iam list-roles --query "Roles[?starts_with(RoleName, 'aws-cloudops-app')].RoleName" --output text 2>/dev/null)
if [ -z "$IAM_ROLES" ] || [ "$IAM_ROLES" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $IAM_ROLES"; fi

echo -n "🔑 Módulo IAM (Policies): "
IAM_POLICIES=$(aws iam list-policies --scope Local --query "Policies[?starts_with(PolicyName, 'aws-cloudops-app')].PolicyName" --output text 2>/dev/null)
if [ -z "$IAM_POLICIES" ] || [ "$IAM_POLICIES" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $IAM_POLICIES"; fi

echo -n "⚡ Módulo Lambda: "
LAMBDA_COUNT=$(aws lambda list-functions --query "Functions[?starts_with(FunctionName, 'aws-cloudops-app')].FunctionName" --output text 2>/dev/null)
if [ -z "$LAMBDA_COUNT" ] || [ "$LAMBDA_COUNT" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $LAMBDA_COUNT"; fi

echo -n "🚀 Módulo API Gateway: "
API_COUNT=$(aws apigatewayv2 get-apis --query "Items[?starts_with(Name, 'aws-cloudops-app')].Name" --output text 2>/dev/null)
if [ -z "$API_COUNT" ] || [ "$API_COUNT" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $API_COUNT"; fi

echo -n "🪣 Módulo S3: "
S3_COUNT=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'aws-cloudops-app')].Name" --output text 2>/dev/null)
if [ -z "$S3_COUNT" ] || [ "$S3_COUNT" = "None" ]; then echo "🟢 OK"; else echo "🔴 PENDENTE: $S3_COUNT"; fi

echo "=================================================="
echo "✨ PROCESSO CONCLUÍDO COM SUCESSO!"
echo "=================================================="
