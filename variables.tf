variable "application_name" {
  type        = string
  description = "The name of the application, used for resource naming and organization."
}

variable "handler" {
  type        = string
  description = "The entry point for the Lambda function (e.g., 'index.handler' for Node.js runtimes)."
}

# TODO allow custom runtime
# variable "lambda_runtime" {
#   type        = string
#   description = "The runtime environment for the Lambda function (e.g., 'nodejs18.x', 'python3.9')."
#   nullable    = true
#   default     = null
# }

variable "image_uri" {
  type        = string
  description = "The URI of the container image to be used for the Lambda function (only applicable for container-based Lambdas)."
  nullable    = true
  default     = null
}

variable "domain_to_certificate" {
  type        = string
  description = "The domain name for which an SSL certificate will be issued."
}

variable "top_level_domain" {
  type        = string
  description = "The top-level domain (TLD) used in conjunction with 'domain_to_certificate'."
}

variable "secret_name" {
  type        = string
  description = "The name of the AWS Secrets Manager secret used by the application."
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables to be injected into the Lambda function."
}

# TODO allow custom runtime
# variable "source_code_hash" {
#   type        = string
#   description = "A base64-encoded SHA256 hash of the Lambda deployment package, used to trigger updates when code changes."
#   nullable    = true
#   default     = null
# }

variable "provisioned_concurrency" {
  type        = number
  description = "The number of provisioned concurrency units allocated to the Lambda function. Defaults to 0 (on-demand execution)."
  default     = 0
}
