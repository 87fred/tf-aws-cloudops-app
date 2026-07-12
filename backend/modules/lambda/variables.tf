variable "project_name" {
  description = "O nome do projeto para identificar os recursos provisionados."
  type        = string
}
variable "workspace" {
  description = "O workspace atual"
  type        = string
}
variable "iam_role_arn" {
  description = "O ARN da role criada no repo de infra"
  type        = string
}
variable "dynamodb_table_name" {
  description = "O nome da tabela do DynamoDB para ser injetado no Lambda"
  type        = string
}