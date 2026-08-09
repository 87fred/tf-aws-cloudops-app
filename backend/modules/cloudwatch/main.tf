# --- 1. Dashboard de Aplicação e Performance - Lambda ---
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "${var.project_name}-lambda-performance-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          metrics = [[
            {
              expression = "SEARCH('{AWS/Lambda,FunctionName} MetricName=\"Errors\" FunctionName^=\"${var.project_name}\"', 'Sum', 60)",
              label      = "Erros Totais (Projeto)", id = "e1"
            }
          ]],
          view = "timeSeries", stacked = false, region = "us-east-1", title = "Erros Totais (Todos os recursos do projeto)", period = 60, stat = "Sum"
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6,
        properties = {
          metrics = [[
            {
              expression = "SEARCH('{AWS/Lambda,FunctionName} MetricName=\"Duration\" FunctionName^=\"${var.project_name}\"', 'Average', 60)",
              label      = "Latência Média (Projeto)", id = "e2"
            }
          ]],
          view = "timeSeries", stacked = false, region = "us-east-1", title = "Latência Média (Todos os recursos do projeto)", period = 60, stat = "Average"
        }
      }
    ]
  })
}

# --- 2. Dashboard de Infraestrutura e Conectividade (CloudFront) ---
resource "aws_cloudwatch_dashboard" "edge_dashboard" {
  dashboard_name = "${var.project_name}-edge-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          metrics = [[
            {
              expression = "SEARCH('{AWS/CloudFront,DistributionId} MetricName=\"Requests\"', 'Sum', 300)",
              label      = "Requisições Totais (Global)", id = "e3"
            }
          ]],
          view = "timeSeries", stacked = false, region = "us-east-1", title = "Requisições Globais (Toda a conta)", period = 300
        }
      }
    ]
  })
}