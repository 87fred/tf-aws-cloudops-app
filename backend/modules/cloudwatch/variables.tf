#Nome da função lambda que será acionada no monitoramento
variable "lambda_function_name" {
  type        = string
  description = "Nome da funcao lmabda a ser monitorada no Cloudwatch"
}

#Período de retenção dos logs em dias para o Log group
variable "retention_in_days" {
  type        = number
  default     = 14
  description = "Numero de dias em que os logs serao retidos no Cloudwatch Logs"
}

# Nome do projeto (usado como prefixo para identificar os dashboards)
variable "project_name" {
  type        = string
  description = "Nome do projeto para prefixar os dashboards"
  default     = "cloudops-app"
}

# ID da distribuição do CloudFront para métricas de borda
variable "cloudfront_distribution_id" {
  type        = string
  description = "ID da distribuicao do CloudFront para monitoramento"
}