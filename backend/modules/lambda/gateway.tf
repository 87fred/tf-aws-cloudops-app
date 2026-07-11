#1. Criar a API Gateway - http
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.project_name}-${var.workspace}-api"
  protocol_type = "HTTP"
}

# 2. Criar a integração com a função Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.backend_lambda.invoke_arn
}

#3. Criar a rota (exemplo: GET /) que aponta para a lambda
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

#4. Dá a permissão para o API gateway invocar o Lambda
resource "aws_lambda_permission" "api_gtlambda" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.backend_lambda.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

#5. Cria um Stage para a API Gateway (Ambiente de publicação da API)
resource "aws_apigatewayv2_stage" "default_stage" {
    api_id = aws_apigatewayv2_api.lambda_api.id
    name = "$default"
    auto_deploy = true
}