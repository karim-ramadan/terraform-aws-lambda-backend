data "aws_iam_policy" "lambda_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_vpc_access" {
  count = var.vpc_config == null ? 0 : 1
  arn   = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name                 = "lambda-execution-${var.application_name}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
}

resource "aws_lambda_function" "this" {
  function_name = var.application_name
  role          = aws_iam_role.lambda_execution_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_vpc_access,
    aws_cloudwatch_log_group.lambda_cloudwatch_group,
  ]
  memory_size                    = var.memory_size
  package_type                   = "Image"
  image_uri                      = var.image_uri
  architectures                  = var.architectures
  timeout                        = var.timeout_seconds
  reserved_concurrent_executions = var.reserved_concurrency
  publish                        = true # Every deploy creates a version; the alias points to it
  tags                           = var.tags

  # Without a command the image's own CMD runs (e.g. a web server behind Lambda Web Adapter)
  dynamic "image_config" {
    for_each = var.image_command == null ? [] : [1]
    content {
      command = var.image_command
    }
  }

  dynamic "environment" {
    for_each = length(var.environment_variables) == 0 ? [] : [1]
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }
}

# Callers invoke the alias, never $LATEST: provisioned concurrency only exists on a
# published version, so invoking the unqualified function would bypass it
resource "aws_lambda_alias" "this" {
  name             = var.alias_name
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  name              = "/aws/lambda/${var.application_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = data.aws_iam_policy.lambda_execution_role.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = var.vpc_config == null ? 0 : 1
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = data.aws_iam_policy.lambda_vpc_access[0].arn
}

resource "aws_lambda_provisioned_concurrency_config" "this" {
  count                             = var.provisioned_concurrency > 0 ? 1 : 0
  function_name                     = aws_lambda_function.this.function_name
  provisioned_concurrent_executions = var.provisioned_concurrency
  qualifier                         = aws_lambda_alias.this.name
}
