# Terraform AWS Lambda Backend Module

This Terraform module provisions a backend using AWS Lambda with a containerized deployment model. It also includes automatic SSL certificate management for secure domain access.

## Features

- Deploys an AWS Lambda function using a Docker container image.
- Configurable runtime and handler for non-containerized deployments.
- Automatic SSL certificate issuance via AWS Certificate Manager (ACM).
- Securely manages secrets using AWS Secrets Manager.
- Supports environment variables for runtime configuration.
- Optionally enables provisioned concurrency for performance optimization.

## Usage

```hcl
module "lambda_backend" {
  source = "github.com/your-repo/terraform-aws-lambda-backend"

  region               = "us-east-1"
  application_name     = "my-app"
  handler             = "index.handler"
  lambda_runtime      = "nodejs18.x"
  image_uri           = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  domain_to_certificate = "api.example.com"
  top_level_domain     = "example.com"
  secret_name         = "my-app-secret"
  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "info"
  }
  source_code_hash = "base64-encoded-sha256-hash"
  provisioned_concurrency = 2
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | `string` | n/a | The AWS region where resources will be deployed. |
| `application_name` | `string` | n/a | The name of the application, used for resource naming and organization. |
| `handler` | `string` | n/a | The entry point for the Lambda function (e.g., `index.handler` for Node.js runtimes). |
| `lambda_runtime` | `string` | `null` | The runtime environment for the Lambda function. Required for non-container deployments. |
| `image_uri` | `string` | `null` | The URI of the container image for the Lambda function. Required for container deployments. |
| `domain_to_certificate` | `string` | n/a | The domain name for which an SSL certificate will be issued. |
| `top_level_domain` | `string` | n/a | The top-level domain (TLD) associated with `domain_to_certificate`. |
| `secret_name` | `string` | n/a | The name of the AWS Secrets Manager secret used by the application. |
| `environment_variables` | `map(string)` | `{}` | A map of environment variables for the Lambda function. |
| `source_code_hash` | `string` | `null` | A base64-encoded SHA256 hash of the Lambda deployment package for update tracking. |
| `provisioned_concurrency` | `number` | `0` | The number of provisioned concurrency units for the Lambda function. |

## Outputs

| Name | Description |
|------|-------------|
| `lambda_function_arn` | The ARN of the deployed Lambda function. |
| `lambda_function_name` | The name of the deployed Lambda function. |
| `api_gateway_url` | The URL of the deployed API Gateway (if applicable). |
| `certificate_arn` | The ARN of the generated SSL certificate. |

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0

## License

This module is licensed under the MIT License.

