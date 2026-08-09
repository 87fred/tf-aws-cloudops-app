output "edge_dashboard_name" {
  description = "Nome do dashboard de borda/infraestrutura"
  value       = aws_cloudwatch_dashboard.edge_dashboard.dashboard_name
}

output "lambda_dashboard_name" {
  description = "Nome do dashboard de performance da Lambda"
  value       = aws_cloudwatch_dashboard.lambda_dashboard.dashboard_name
}