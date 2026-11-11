variable "application_name" {
  type        = string
  description = "Application name, used for the function, API and role names"
}

variable "image_uri" {
  type        = string
  description = "URI of the container image (ECR) for the Lambda function"
}

variable "image_command" {
  type        = list(string)
  default     = null
  description = "Overrides the image CMD (e.g. [\"lambda.handler\"]). Leave null to run the image's own CMD"
}

variable "architectures" {
  type        = list(string)
  default     = ["x86_64"]
  description = "Instruction set of the image: [\"x86_64\"] or [\"arm64\"]"
}

variable "memory_size" {
  type        = number
  default     = 512
  description = "Memory size in MB"
}

variable "timeout_seconds" {
  type        = number
  default     = 30
  description = "Function timeout in seconds. Above 29 only takes effect with response_streaming"

  validation {
    condition     = var.timeout_seconds >= 1 && var.timeout_seconds <= 900
    error_message = "timeout_seconds must be between 1 and 900."
  }
}

variable "log_retention_days" {
  type        = number
  default     = 14
  description = "Retention of the function's CloudWatch logs"
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables for the Lambda function"
  default     = {}
}

variable "secret_arns" {
  type        = list(string)
  default     = []
  description = "ARNs of the Secrets Manager secrets the function may read"
}

variable "provisioned_concurrency" {
  type        = number
  default     = 0
  description = "Provisioned concurrency on the function alias (0 disables it)"
}

variable "reserved_concurrency" {
  type        = number
  default     = -1
  description = "Reserved concurrent executions (-1 means unreserved)"
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default     = null
  description = "Runs the function inside a VPC when set"
}

variable "domain_to_certificate" {
  type        = string
  description = "The domain name the API is served on; an SSL certificate is issued for it"
}

variable "top_level_domain" {
  type        = string
  description = "The Route53 hosted zone (TLD) associated with domain_to_certificate"
}

variable "response_streaming" {
  type        = bool
  default     = false
  description = "Stream the function's response (InvokeWithResponseStream). The function must stream too, e.g. Lambda Web Adapter with AWS_LWA_INVOKE_MODE=response_stream"
}

variable "integration_timeout_milliseconds" {
  type        = number
  default     = null
  description = "API Gateway integration timeout. Defaults to 29000, or to the function timeout (max 900000) with response_streaming"
}

variable "binary_media_types" {
  type        = list(string)
  default     = []
  description = "Content types API Gateway treats as binary (e.g. [\"application/octet-stream\", \"multipart/form-data\"])"
}

variable "stage_name" {
  type        = string
  default     = "api"
  description = "Name of the API Gateway stage (not visible behind the custom domain)"
}

variable "throttling_burst_limit" {
  type        = number
  default     = 100
  description = "API-wide burst limit (requests)"
}

variable "throttling_rate_limit" {
  type        = number
  default     = 50
  description = "API-wide steady-state limit (requests per second)"
}

variable "access_logs_enabled" {
  type        = bool
  default     = false
  description = "Write API Gateway access logs. Requires the account-level API Gateway CloudWatch role (aws_api_gateway_account) to be set"
}

variable "access_log_retention_days" {
  type        = number
  default     = 14
  description = "Retention of the API Gateway access logs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the resources that support them"
}
