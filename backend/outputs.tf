# ==============================================================================
# OUTPUTS DINÂMICOS 
# ==============================================================================

# --- Módulo S3 (Frontend) ---
output "frontend_bucket_name" {
  description = "Nome do bucket S3 do frontend gerado pela AWS"
  value       = module.s3.bucket_name
}

output "frontend_bucket_arn" {
  description = "ARN do bucket S3 do frontend"
  value       = module.s3.bucket_arn
}

# --- Módulo CloudFront (CDN) ---
output "cloudfront_distribution_id" {
  description = "ID da distribuição do CloudFront"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "URL pública da CDN do CloudFront"
  value       = module.cloudfront.cloudfront_domain_name
}

# --- Módulo Backend (Lambda & API Gateway) ---
output "backend_api_url" {
  description = "URL do endpoint do API Gateway"
  value       = module.lambda_backend.api_url
}

output "backend_lambda_function_name" {
  description = "Nome da função Lambda do backend"
  value       = module.lambda_backend.function_name
}

# --- Módulo DynamoDB ---
output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = module.dynamodb_backend.table_name
}