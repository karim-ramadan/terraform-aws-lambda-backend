variable "application_name" {
  type        = string
  description = "Application name, used as the function name"
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

variable "environment_variables" {
  type        = map(string)
  description = "A map of environment variables for the Lambda function"
  default     = {}
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
  description = "Memory size in MB"
}

variable "alias_name" {
  type        = string
  default     = "live"
  description = "Name of the alias that points to the latest published version"
}

variable "provisioned_concurrency" {
  type        = number
  default     = 0
  description = "Provisioned concurrency on the alias (0 disables it)"
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the resources that support them"
}
