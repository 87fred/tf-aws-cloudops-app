output "api_url" {
  value = module.lambda_backend.api_url
}
output "bucket_name" {
  description = "Nome da bucket criada"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "ARN do bucket criado"
  value       = module.s3.bucket_arn
}