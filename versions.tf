terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.26.0" # aws_api_gateway_integration.response_transfer_mode with 900s timeouts
    }
  }
}
