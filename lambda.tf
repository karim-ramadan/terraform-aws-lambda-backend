module "lambda" {
  source                  = "./modules/lambda"
  application_name        = var.application_name
  environment_variables   = var.environment_variables
  handler                 = var.handler
  image_uri               = var.image_uri
  region                  = var.region
  runtime                 = var.lambda_runtime
  source_code_hash        = var.source_code_hash
  provisioned_concurrency = var.provisioned_concurrency
}