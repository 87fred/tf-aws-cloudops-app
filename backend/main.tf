#1. Orquestra a criação do Banco de dados DynamoDB
module "dynamodb_backend" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  workspace    = terraform.workspace
}


#2 Orquestra a criação do IAM
module "iam_backend" {
  source              = "./modules/iam"
  project_name        = var.project_name
  workspace           = terraform.workspace
  dynamodb_table_name = module.dynamodb_backend.tabela_arn
}

#3. Lambda consome o ARN criado pelo módulo IAM
module "lambda_backend" {
  source              = "./modules/lambda"
  project_name        = var.project_name
  workspace           = terraform.workspace
  iam_role_arn        = module.iam_backend.lambda_role_arn
  dynamodb_table_name = module.dynamodb_backend.table_name
}

#4. Orquestra a criação do S3 para hospedar o frontend
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

#5. Orquestra a criação do CloudFront para entregar o frontend
module "cloudfront" {
  source      = "./modules/cloudfront"
  bucket_name = module.s3.bucket_name
  bucket_arn  = module.s3.bucket_arn
}