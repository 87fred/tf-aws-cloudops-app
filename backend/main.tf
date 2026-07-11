#1. Orquestra a criação do IAM
module "iam_backend" {
  source       = "./modules/iam"
  project_name = var.project_name
  workspace = terraform.workspace
}

#2. Lambda consome o ARN criado pelo módulo IAM
module "lambda_backend" {
  source       = "./modules/lambda"
  project_name = var.project_name
  workspace    = terraform.workspace
  iam_role_arn = module.iam_backend.lambda_role_arn
}