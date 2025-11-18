# Variable validation tests

run "validate_required_variables" {
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
    condition     = var.region == "us-east-1"
    error_message = "Region variable should be set correctly"
  }

  assert {
    condition     = var.application_name == "test-app"
    error_message = "Application name variable should be set correctly"
  }

  assert {
    condition     = var.handler == "index.handler"
    error_message = "Handler variable should be set correctly"
  }

  assert {
    condition     = var.domain_to_certificate == "api.test.example.com"
    error_message = "Domain to certificate variable should be set correctly"
  }

  assert {
    condition     = var.top_level_domain == "test.example.com"
    error_message = "Top level domain variable should be set correctly"
  }

  assert {
    condition     = var.secret_name == "test-secret"
    error_message = "Secret name variable should be set correctly"
  }
}

run "validate_optional_variables" {
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
      ENV     = "test"
      LOG_LEVEL = "debug"
    }
    source_code_hash     = "dGVzdC1oYXNo"
    provisioned_concurrency = 1
    lambda_runtime       = null
  }

  assert {
    condition     = length(var.environment_variables) == 2
    error_message = "Environment variables should contain 2 items"
  }

  assert {
    condition     = var.source_code_hash == "dGVzdC1oYXNo"
    error_message = "Source code hash should be set correctly"
  }

  assert {
    condition     = var.provisioned_concurrency == 1
    error_message = "Provisioned concurrency should be set correctly"
  }
}

