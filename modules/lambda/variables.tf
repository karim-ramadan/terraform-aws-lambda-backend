variable "application_name" {
  type        = string
  description = "Application name"
}

variable "handler" {
  type        = string
  description = "Lambda function handler"
}

# TODO allow custom runtime
# variable "runtime" {
#   type        = string
#   description = "Lambda funtion runtime"
#   nullable    = true
#   default     = null
# }

variable "image_uri" {
  type        = string
  description = "Lambda image uri"
  nullable    = true
  default     = null
}

variable "environment_variables" {
  type = map(string)
}

# TODO allow source code hash
# variable "source_code_hash" {
#   type     = string
#   nullable = true
#   default  = null
# }

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "log_retention_days" {
  type    = number
  default = 14
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