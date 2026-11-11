data "aws_region" "current" {}

locals {
  # Streaming calls Lambda's InvokeWithResponseStream through a different URI;
  # both forms target the alias so provisioned concurrency is used
  integration_uri = (var.response_streaming
    ? "arn:aws:apigateway:${data.aws_region.current.region}:lambda:path/2021-11-15/functions/${module.lambda.alias.arn}/response-streaming-invocations"
    : module.lambda.alias.invoke_arn
  )
  integration_timeout_milliseconds = coalesce(
    var.integration_timeout_milliseconds,
    var.response_streaming ? min(var.timeout_seconds * 1000, 900000) : 29000
  )

  api_resources = {
    root  = aws_api_gateway_rest_api.this.root_resource_id
    proxy = aws_api_gateway_resource.proxy.id
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name               = var.application_name
  binary_media_types = var.binary_media_types
  tags               = var.tags

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

# ANY on "/" and "/{proxy+}": every request goes to the function
resource "aws_api_gateway_method" "this" {
  for_each = local.api_resources

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  for_each = local.api_resources

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.integration_uri
  response_transfer_mode  = var.response_streaming ? "STREAM" : "BUFFERED"
  timeout_milliseconds    = local.integration_timeout_milliseconds
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # The alias ARN is stable, so new images don't need a new deployment; only API changes do
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
  tags          = var.tags

  # Needs the account-level API Gateway CloudWatch role (aws_api_gateway_account)
  dynamic "access_log_settings" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn

      format = jsonencode({
        requestId               = "$context.requestId"
        sourceIp                = "$context.identity.sourceIp"
        requestTime             = "$context.requestTime"
        protocol                = "$context.protocol"
        httpMethod              = "$context.httpMethod"
        resourcePath            = "$context.resourcePath"
        status                  = "$context.status"
        responseLength          = "$context.responseLength"
        integrationLatency      = "$context.integration.latency"
        integrationErrorMessage = "$context.integrationErrorMessage"
      })
    }
  }
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  count             = var.access_logs_enabled ? 1 : 0
  name              = "/aws/api_gw/${var.application_name}"
  retention_in_days = var.access_log_retention_days
  tags              = var.tags
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = var.domain_to_certificate
  regional_certificate_arn = aws_acm_certificate_validation.this.certificate_arn
  security_policy          = "TLS_1_2"
  tags                     = var.tags

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

//Used to connect the custom domain to the api gateway stage
resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name
}

resource "aws_route53_record" "this" {
  name    = aws_api_gateway_domain_name.this.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function.function_name
  qualifier     = module.lambda.alias.name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
