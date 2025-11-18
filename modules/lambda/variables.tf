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

variable "runtime" {
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

variable "timeout_seconds" {
  type        = number
  default     = 60
  description = "The maximum duration in seconds that the Lambda function can run before timing out"
}

variable "log_retention_days" {
  type        = number
  default     = 14
  description = "The number of days to retain logs in CloudWatch Logs for the Lambda function"
}

variable "memory_size" {
  type        = number
  default     = 512
  description = "Memory size in Gigabyte"
}

variable "provisioned_concurrency" {
  type        = number
  default     = 0
  description = "Provisioned concurrency for lambda"
}