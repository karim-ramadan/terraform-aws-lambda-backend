module "lambda" {
  source                  = "./modules/lambda"
  application_name        = var.application_name
  image_uri               = var.image_uri
  image_command           = var.image_command
  architectures           = var.architectures
  memory_size             = var.memory_size
  timeout_seconds         = var.timeout_seconds
  log_retention_days      = var.log_retention_days
  environment_variables   = var.environment_variables
  provisioned_concurrency = var.provisioned_concurrency
  reserved_concurrency    = var.reserved_concurrency
  vpc_config              = var.vpc_config
  permissions_boundary    = var.permissions_boundary
  tags                    = var.tags
}
