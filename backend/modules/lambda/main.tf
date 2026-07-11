resource "aws_lambda_function" "backend_lambda" {
  function_name = "${var.project_name}-${terraform.workspace}-backend"
  role          = var.iam_role_arn
  handler       = "main.handler"
  runtime       = "python3.11"

# Apenas apontamos para onde o arquivo ESTARÁ. 
  # O Terraform não vai falhar se ele ainda não existir, 
  # a menos que você tente rodar o 'apply'.
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
    }
  }
}
# Cria o arquivo ZIP automaticamente a partir do código Python
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/main.py"
  output_path = "${path.module}/lambda_functions.zip"
}
