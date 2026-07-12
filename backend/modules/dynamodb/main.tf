resource "aws_dynamodb_table" "dynamodb_table" {
  name         = "${var.project_name}-${terraform.workspace}-users"
  billing_mode = "PAY_PER_REQUEST"

  # Chave primária da tabela será o email/username do usuário
  hash_key = "username"

  #Definindo o tipo do atributo que será a chave primária da tabela (S = String)
  attribute {
    name = "username"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-${terraform.workspace}-users"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}