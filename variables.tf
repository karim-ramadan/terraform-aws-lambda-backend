variable "region" {
  type        = string
  description = "AWS Region"
}

variable "application_name" {
  type        = string
  description = "Application name"
}

variable "handler" {
  type        = string
  description = "Lambda function handler"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda funtion runtime"
  nullable    = true
  default     = null
}

variable "image_uri" {
  type        = string
  description = "Lambda image uri"
  nullable    = true
  default     = null
}

variable "domain_to_certificate" {
  type        = string
  description = "The domain name for which an SSL certificate will be issued"
}

variable "top_level_domain" {
  type        = string
  description = "The top-level domain (TLD) associated with domain_to_certificate"
}

variable "secret_name" {
  type        = string
  description = "The name of the AWS Secrets Manager secret used by the application"
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables for the Lambda function"
  default     = {}
}

variable "source_code_hash" {
  type        = string
  nullable    = true
  default     = null
  description = "A base64-encoded SHA256 hash of the Lambda deployment package for update tracking"
}

variable "provisioned_concurrency" {
  type        = number
  default     = 0
  description = "Provisioned concurrency lambda"
}
