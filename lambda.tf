module "lambda" {
  source                  = "./modules/lambda"
  application_name        = var.application_name
  environment_variables   = var.environment_variables
  handler                 = var.handler
  image_uri               = var.image_uri
  provisioned_concurrency = var.provisioned_concurrency
}