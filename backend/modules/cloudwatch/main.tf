#Criação do grupo de logs no Cloudwatc para a função lambda especificada
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.retention_in_days
}

#Configuração de alarme de métrica para monitorar erros na função Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_erros" {
  alarm_name          = "/${var.lambda_function_name}-erros-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarme disparado se a funcao Lambda registrar 1 ou mais erros no periodo."

  # Associa o alarme diretamente à Lambda através das dimensões do CloudWatch
  dimensions = {
    FunctionName = var.lambda_function_name
  }

}




    