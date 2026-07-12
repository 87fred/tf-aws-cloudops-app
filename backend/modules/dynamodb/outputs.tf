output "tabela_arn" {
  description = "ARN da tabela DynamoDB para permissões no IAM"
  value       = aws_dynamodb_table.dynamodb_table.arn
}

output "table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.dynamodb_table.name
}