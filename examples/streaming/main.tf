provider "aws" {
  region = "eu-central-1"
}

# A web server in a container (here: Lambda Web Adapter in response_stream mode)
# behind a streaming REST API on api.example.com
module "backend" {
  source = "../.."

  application_name      = "my-app"
  image_uri             = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/my-app:sha-abc123"
  architectures         = ["arm64"]
  memory_size           = 1024
  timeout_seconds       = 300
  response_streaming    = true
  domain_to_certificate = "api.example.com"
  top_level_domain      = "example.com"
  secret_arns           = ["arn:aws:secretsmanager:eu-central-1:123456789012:secret:my-app-AbCdEf"]

  environment_variables = {
    AWS_LWA_INVOKE_MODE          = "response_stream"
    AWS_LWA_PORT                 = "3000"
    AWS_LWA_READINESS_CHECK_PATH = "/health"
  }
}

output "api_url" {
  value = module.backend.api_gateway_url
}
