module "lambda_backend" {
  source = "./modules/lambda"

  project_name  = var.project_name
  workspace  = terraform.workspace
  iam_role_arn  = var.iam_role_arn
}