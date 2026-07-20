# Retorna o nome do Log group criado par a funçao lambda
output "log_group_name" {
  value = aws_cloudwatch_log_group.lambda_logs.name
}

#Retorna o arn (Amazon Resource Name) do alarme de erros configurado
output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.lambda_errors.arn
}
