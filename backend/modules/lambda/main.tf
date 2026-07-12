resource "aws_lambda_function" "backend_lambda" {
  function_name = "${var.project_name}-${terraform.workspace}-backend"
  role          = var.iam_role_arn
  handler       = "main.handler"
  runtime       = "python3.11"


  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT    = terraform.workspace
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }
}
# Cria o arquivo ZIP automaticamente a partir do código Python
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_functions.zip"
}
