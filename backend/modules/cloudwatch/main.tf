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

#1. Dashboard de Aplicação e Performance - Lambda
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "${var.project_name}-lambda-performance-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name],
            [".", "Invocations", ".", "."]
          ],
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Erros e Invocacoes - Lambda"
          period  = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name]
          ],
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Latencia (Duration) - Lambda"
          period  = 60
          stat    = "Average"
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# 2. Dashboard de Infraestrutura e Conectividade (CloudFront / Borda)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "edge_dashboard" {
  dashboard_name = "${var.project_name}-edge-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id],
            [".", "BytesDownloaded", ".", "."],
            [".", "BytesUploaded", ".", "."]
          ],
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Requisicoes e Trafego - CloudFront"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudFront", "TotalErrorRate", "DistributionId", var.cloudfront_distribution_id],
            [".", "5xxErrorRate", ".", "."],
            [".", "4xxErrorRate", ".", "."]
          ],
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Taxa de Erros HTTP (4xx / 5xx) - Borda"
          period  = 300
          stat    = "Average"
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# 3. Dashboard de FinOps e Custos (AWS Billing)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "finops_dashboard" {
  dashboard_name = "${var.project_name}-finops-costs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ],
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1" # Nota: Métricas de Billing na AWS ficam obrigatoriamente em us-east-1
          title   = "Custo Estimado Consolidado (USD)"
          period  = 21600
          stat    = "Maximum"
        }
      }
    ]
  })
}