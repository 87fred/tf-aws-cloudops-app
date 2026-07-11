resource "aws_lambda_function" "backend_lambda" {
  function_name = "${var.project_name}-${terraform.workspace}-backend"
  role          = var.iam_role_arn
  handler       = "main.handler"
  runtime       = "python3.11"

# Apenas apontamos para onde o arquivo ESTARÁ. 
  # O Terraform não vai falhar se ele ainda não existir, 
  # a menos que você tente rodar o 'apply'.
  filename      = "modules/lambda/lambda_functions.zip"

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
    }
  }
}