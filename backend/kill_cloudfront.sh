#!/bin/bash
set -e

DIST_ID="E2GJBFS9C4XNL7"

echo "🎯 FOCANDO APENAS NO CLOUDFRONT ($DIST_ID)"
echo "------------------------------------------"

# 1. Pega o ETag atual
ETAG=$(aws cloudfront get-distribution-config --id "$DIST_ID" --query "ETag" --output text)

# 2. Modifica a origem limpando OAC e adicionando CustomOriginConfig
echo "⚙️ [1/2] Desativando a distribuição e limpando OAC..."
aws cloudfront get-distribution-config --id "$DIST_ID" --query "DistributionConfig" | \
python3 -c '
import sys, json
d = json.load(sys.stdin)
d["Enabled"] = False

if "Origins" in d and "Items" in d["Origins"] and len(d["Origins"]["Items"]) > 0:
    origin = d["Origins"]["Items"][0]
    origin["DomainName"] = "example.com"
    origin["CustomOriginConfig"] = {
        "HTTPPort": 80,
        "HTTPSPort": 443,
        "OriginProtocolPolicy": "http-only",
        "OriginSslProtocols": {"Quantity": 1, "Items": ["TLSv1.2"]},
        "OriginReadTimeout": 30,
        "OriginKeepaliveTimeout": 5
    }
    # Limpa referências a S3 e OAC para não dar conflito de Origin Type
    if "S3OriginConfig" in origin:
        del origin["S3OriginConfig"]
    if "OriginAccessControlId" in origin:
        origin["OriginAccessControlId"] = ""

print(json.dumps(d))
' > /tmp/cf-kill.json

# 3. Atualiza no CloudFront
aws cloudfront update-distribution --id "$DIST_ID" --if-match "$ETAG" --distribution-config file:///tmp/cf-kill.json > /dev/null

echo "✅ Distribuição desabilitada com sucesso na AWS!"
echo ""
echo "⏳ Aguardando a AWS propagar a alteração para deletar definitivamente..."

# 4. Loop aguardando o status "Deployed" para deletar
while true; do
    STATUS=$(aws cloudfront get-distribution --id "$DIST_ID" --query "Distribution.Status" --output text)
    echo "   Status atual: $STATUS..."
    if [ "$STATUS" = "Deployed" ]; then
        echo "🔥 Status 'Deployed' atingido! Deletando distribuição..."
        NEW_ETAG=$(aws cloudfront get-distribution-config --id "$DIST_ID" --query "ETag" --output text)
        aws cloudfront delete-distribution --id "$DIST_ID" --if-match "$NEW_ETAG"
        echo "💥 CloudFront $DIST_ID DELETADO DEFINITIVAMENTE!"
        break
    fi
    sleep 15
done
