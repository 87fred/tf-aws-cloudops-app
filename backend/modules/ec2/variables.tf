variable "environment" {
  description = "Ambiente de implantação (ex: dev, prod, default)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Nome do projeto para uso em tags"
  type        = string
  default     = "aws-cloudops-app"
}

