variable "aws_region" {
  description = "A região que os recursos da AWS serão provisionados."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "O nome do projeto para identificar os recursos provisionados."
  type        = string
  default     = "aws-cloudops-app"
}

variable "iam_role_arn" {
  description = "O ARN da role criada no repo de infra"
  type        = string
  default     = "string"
}