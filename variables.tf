variable region {
  type        = string
  description = "AWS Region"
}

variable application_name {
  type        = string
  description = "Application name"
}

variable handler {
  type        = string
  description = "Lambda function handler"
}

variable lambda_runtime {
  type        = string
  description = "Lambda funtion runtime"
  nullable    = true
  default     = null
}

variable image_uri {
  type        = string
  description = "Lambda image uri"
  nullable    = true
  default     = null
}

variable "domain_to_certificate" {
  type = string
}

variable "top_level_domain" {
  type = string
}

variable "secret_name" {
  type = string
}

variable "environment_variables" {
  type = map(string)
}

variable source_code_hash {
  type     = string
  nullable = true
  default  = null
}

variable provisioned_concurrency {
  type     = number
  default  = 0
  description = "Provisioned concurrency lambda"
}
