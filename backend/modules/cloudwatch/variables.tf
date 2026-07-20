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