# Retorna o nome do Log Group criado para a função Lambda
output "log_group_name" {
  description = "Nome do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

# Retorna o ARN (Amazon Resource Name) do alarme de erros configurado
output "alarm_arn" {
  description = "ARN do alarme de erros do CloudWatch"
  value       = aws_cloudwatch_metric_alarm.lambda_erros.arn
}