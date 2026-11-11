# Runs without AWS credentials: every call goes to a mocked provider
mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "eu-central-1"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  # Known at plan time, so the validation records' for_each can be planned
  mock_resource "aws_acm_certificate" {
    override_during = plan
    defaults = {
      domain_validation_options = [{
        domain_name           = "api.example.com"
        resource_record_name  = "_abc.api.example.com."
        resource_record_type  = "CNAME"
        resource_record_value = "_def.acm-validations.aws."
      }]
    }
  }

  mock_resource "aws_lambda_alias" {
    override_during = plan
    defaults = {
      arn        = "arn:aws:lambda:eu-central-1:123456789012:function:app:live"
      invoke_arn = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:123456789012:function:app:live/invocations"
    }
  }
}

variables {
  application_name      = "app"
  image_uri             = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/app:1"
  domain_to_certificate = "api.example.com"
  top_level_domain      = "example.com"
}

run "buffered_invokes_alias" {
  command = plan

  assert {
    condition     = alltrue([for i in aws_api_gateway_integration.this : i.uri == module.lambda.alias.invoke_arn])
    error_message = "API Gateway must invoke the alias, not $LATEST"
  }

  assert {
    condition     = alltrue([for i in aws_api_gateway_integration.this : i.response_transfer_mode == "BUFFERED" && i.timeout_milliseconds == 29000])
    error_message = "Buffered integrations keep the 29s timeout"
  }

  assert {
    condition     = aws_lambda_permission.api_gw.qualifier == "live"
    error_message = "The invoke permission must be granted on the alias"
  }

  assert {
    condition     = length(aws_iam_role_policy.secrets_manager_read) == 0 && length(aws_cloudwatch_log_group.api_gw) == 0
    error_message = "No secrets policy or access log group unless asked for"
  }
}

run "streaming_invokes_alias_with_response_stream" {
  command = plan

  variables {
    response_streaming = true
    timeout_seconds    = 300
    secret_arns        = ["arn:aws:secretsmanager:eu-central-1:123456789012:secret:app-AbCdEf"]
  }

  assert {
    condition     = alltrue([for i in aws_api_gateway_integration.this : i.uri == "arn:aws:apigateway:eu-central-1:lambda:path/2021-11-15/functions/arn:aws:lambda:eu-central-1:123456789012:function:app:live/response-streaming-invocations"])
    error_message = "Streaming must call the alias through response-streaming-invocations"
  }

  assert {
    condition     = alltrue([for i in aws_api_gateway_integration.this : i.response_transfer_mode == "STREAM" && i.timeout_milliseconds == 300000])
    error_message = "Streaming integrations use STREAM and the function timeout"
  }

  assert {
    condition     = length(aws_iam_role_policy.secrets_manager_read) == 1
    error_message = "Secret ARNs grant read access"
  }
}

run "provisioned_concurrency_on_alias" {
  command = plan

  module {
    source = "./modules/lambda"
  }

  variables {
    provisioned_concurrency = 2
  }

  assert {
    condition     = aws_lambda_provisioned_concurrency_config.this[0].qualifier == aws_lambda_alias.this.name
    error_message = "Provisioned concurrency must sit on the alias API Gateway invokes"
  }

  assert {
    condition     = length(aws_lambda_function.this.image_config) == 0
    error_message = "Without image_command the image's own CMD runs"
  }
}
