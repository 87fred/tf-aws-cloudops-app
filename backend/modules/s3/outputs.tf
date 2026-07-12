output "bucket_name" {
  description = "Nome da bucket criada"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "bucket_arn" {
  description = "ARN do bucket criado"
  value       = aws_s3_bucket.frontend_bucket.arn
}

