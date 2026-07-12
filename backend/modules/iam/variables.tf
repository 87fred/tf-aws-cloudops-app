variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "workspace" {
  description = "The Terraform workspace"
  type        = string
}

variable "dynamodb_table_name" {
  description = "ARN da tabela do Dynamodb para conceder permissões no IAM"
  type        = string
}