module "dynamodb" {
  source            = "../modules/dynamodb"
  env               = var.env
  prefix            = var.prefix
  table_name_suffix = "requests-db"
}

module "iam" {
  source       = "../modules/iam"
  role_name    = "lambda-role"
  env          = var.env
  prefix       = var.prefix
  dynamodb_arn = module.dynamodb.arn
}

module "lambda" {
  source        = "../modules/lambda"
  function_name = "health-check-function"
  env           = var.env
  prefix        = var.prefix
  role_arn      = module.iam.role_arn
  table_name    = module.dynamodb.name
  package       = "../lambda/lambda.zip"
  package_hash  = var.lambda_package_hash
}

module "api" {
  source            = "../modules/apigateway"
  api_gateway_name  = "health-api"
  env               = var.env
  prefix            = var.prefix
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_name       = module.lambda.name
}
