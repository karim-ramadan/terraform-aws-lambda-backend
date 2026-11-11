# Changelog

## v2.1.0

- `permissions_boundary`: attach a permissions boundary to the execution role (root module and `modules/lambda`), for deploy roles that may only create bounded roles.

## v2.0.0

### Breaking

- **HTTP API replaced by a regional REST API.** The `aws_apigatewayv2_*` resources are destroyed and `aws_api_gateway_*` ones created; the custom domain and Route53 record are recreated, so expect a short interruption on the API domain while it switches.
- `secret_name` (an existing secret, looked up by name) is replaced by `secret_arns` (a list). Pass `data.aws_secretsmanager_secret.x.arn` to keep the old behaviour.
- `handler` is replaced by `image_command` (a list, optional). Use `image_command = ["lambda.handler"]` for the old behaviour; leave it unset to run the image's CMD.
- Removed `region` (unused), `lambda_runtime` and `source_code_hash` (no effect on image functions).
- Requires AWS provider >= 6.26.0 and Terraform >= 1.5.
- API Gateway access logs are off by default (`access_logs_enabled`), since REST APIs need the account CloudWatch role. The log group is now `/aws/api_gw/<application_name>`.

### Fixed

- Provisioned concurrency was paid for but never used: API Gateway invoked the unqualified function (`$LATEST`) while provisioned concurrency sat on the published version. Traffic now goes through the `live` alias, which carries the provisioned concurrency.

### Added

- `response_streaming`, `integration_timeout_milliseconds`, `binary_media_types`, `stage_name`.
- `architectures`, `memory_size`, `timeout_seconds`, `log_retention_days`, `reserved_concurrency`, `vpc_config`, `tags`.
- API-wide throttling (`throttling_burst_limit`, `throttling_rate_limit`).
- Outputs `lambda_alias_arn`, `lambda_role_name`, `api_gateway_invoke_url`, `rest_api_id`.
- `terraform test` suite with a mocked provider, and `examples/streaming`.

## v1.1.0 and earlier

Container Lambda behind an HTTP API with a custom domain. No changelog was kept; see the git history.
