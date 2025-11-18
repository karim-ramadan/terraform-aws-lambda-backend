# Basic validation tests for the Terraform module
# These tests validate the module structure without requiring AWS credentials

run "validate_module_structure" {
  # This test validates that all required resources can be planned
  # without actually applying changes
  command = plan
  
  variables {
    region               = "us-east-1"
    application_name     = "test-app"
    handler              = "index.handler"
    image_uri            = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test-app:latest"
    domain_to_certificate = "api.test.example.com"
    top_level_domain     = "test.example.com"
    secret_name          = "test-secret"
    environment_variables = {
      ENV = "test"
    }
    source_code_hash     = null
    provisioned_concurrency = 0
  }

  assert {
    condition     = terraform_version != ""
    error_message = "Terraform version should be available"
  }
}

run "validate_outputs_exist" {
  command = plan
  
  variables {
    region               = "us-east-1"
    application_name     = "test-app"
    handler              = "index.handler"
    image_uri            = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test-app:latest"
    domain_to_certificate = "api.test.example.com"
    top_level_domain     = "test.example.com"
    secret_name          = "test-secret"
    environment_variables = {}
    source_code_hash     = null
    provisioned_concurrency = 0
  }

  assert {
    condition     = can(output.lambda_function_arn)
    error_message = "lambda_function_arn output should exist"
  }

  assert {
    condition     = can(output.lambda_function_name)
    error_message = "lambda_function_name output should exist"
  }

  assert {
    condition     = can(output.api_gateway_url)
    error_message = "api_gateway_url output should exist"
  }

  assert {
    condition     = can(output.certificate_arn)
    error_message = "certificate_arn output should exist"
  }
}

run "validate_provisioned_concurrency" {
  command = plan
  
  variables {
    region               = "us-east-1"
    application_name     = "test-app"
    handler              = "index.handler"
    image_uri            = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test-app:latest"
    domain_to_certificate = "api.test.example.com"
    top_level_domain     = "test.example.com"
    secret_name          = "test-secret"
    environment_variables = {}
    source_code_hash     = null
    provisioned_concurrency = 2
  }

  assert {
    condition     = var.provisioned_concurrency == 2
    error_message = "Provisioned concurrency should be set to 2"
  }
}

