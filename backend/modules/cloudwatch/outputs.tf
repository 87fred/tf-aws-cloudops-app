# Retorna o ARN (Amazon Resource Name) do alarme de erros configurado
output "alarm_arn" {
  description = "ARN do alarme de erros do CloudWatch"
  value       = aws_cloudwatch_metric_alarm.lambda_erros.arn
}