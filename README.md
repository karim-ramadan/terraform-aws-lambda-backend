# Terraform AWS Lambda Backend Module

This Terraform module deploys a container-image AWS Lambda function behind an API Gateway REST API on a custom domain, with a DNS-validated ACM certificate and optional response streaming.

## Features

- Deploys a Lambda function from a container image (ECR), on `x86_64` or `arm64`.
- Publishes a version on every deploy and routes traffic through an alias (`live`), so provisioned concurrency is actually used.
- Regional REST API (`ANY /` and `ANY /{proxy+}`) with API-wide throttling.
- Optional **response streaming** (`InvokeWithResponseStream`): first bytes reach the client immediately and requests can run up to 15 minutes instead of 29 seconds.
- Issues and DNS-validates an ACM certificate and creates the Route53 alias record.
- Grants read access to the Secrets Manager secrets you pass by ARN.
- Optional VPC placement, reserved concurrency and API Gateway access logs.

## Usage

```hcl
module "backend" {
  source = "github.com/karim-ramadan/terraform-aws-lambda-backend?ref=v2.0.0"

  application_name      = "my-app"
  image_uri             = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/my-app:sha-abc123"
  domain_to_certificate = "api.example.com"
  top_level_domain      = "example.com"
  secret_arns           = [aws_secretsmanager_secret.app.arn]

  environment_variables = {
    LOG_LEVEL = "info"
  }
}
```

### Response streaming

Set `response_streaming = true`. The function must stream as well. The simplest way for an
HTTP server (Express, NestJS, Fastify, …) is [Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter):
add it to the image and set `AWS_LWA_INVOKE_MODE=response_stream`. See [`examples/streaming`](examples/streaming/main.tf).

With streaming the integration timeout follows `timeout_seconds` (up to 900). Streams that stay
idle for more than 5 minutes are closed by API Gateway.

### Provisioned concurrency

Provisioned concurrency sits on the `live` alias. Each deploy moves the alias to the new version and AWS
re-provisions the warm instances for it, which takes a few minutes; until then requests may hit cold starts.
Published versions are not deleted.

### Access logs

REST API access logs need the account-wide API Gateway CloudWatch role
(`aws_api_gateway_account`). Set it once per account and region, then enable
`access_logs_enabled`.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `application_name` | `string` | n/a | Name of the function, API and role. |
| `image_uri` | `string` | n/a | URI of the container image. |
| `domain_to_certificate` | `string` | n/a | Domain the API is served on; a certificate is issued for it. |
| `top_level_domain` | `string` | n/a | Route53 hosted zone of `domain_to_certificate`. |
| `image_command` | `list(string)` | `null` | Overrides the image CMD (e.g. `["lambda.handler"]`). `null` runs the image's own CMD. |
| `architectures` | `list(string)` | `["x86_64"]` | `["x86_64"]` or `["arm64"]`. |
| `memory_size` | `number` | `512` | Memory in MB. |
| `timeout_seconds` | `number` | `30` | Function timeout (1–900). Above 29 only matters with streaming. |
| `log_retention_days` | `number` | `14` | Retention of the function logs. |
| `environment_variables` | `map(string)` | `{}` | Environment variables of the function. |
| `secret_arns` | `list(string)` | `[]` | Secrets Manager secrets the function may read. |
| `provisioned_concurrency` | `number` | `0` | Provisioned concurrency on the `live` alias. |
| `reserved_concurrency` | `number` | `-1` | Reserved concurrency (`-1` = unreserved). |
| `vpc_config` | `object` | `null` | `{ subnet_ids, security_group_ids }` to run in a VPC. |
| `response_streaming` | `bool` | `false` | Stream responses (see above). |
| `integration_timeout_milliseconds` | `number` | `null` | Override the integration timeout (default 29000, or the function timeout with streaming). |
| `binary_media_types` | `list(string)` | `[]` | Content types API Gateway treats as binary. |
| `stage_name` | `string` | `"api"` | Stage name (hidden behind the custom domain). |
| `throttling_burst_limit` | `number` | `100` | API-wide burst limit. |
| `throttling_rate_limit` | `number` | `50` | API-wide requests per second. |
| `access_logs_enabled` | `bool` | `false` | Write access logs (needs the account CloudWatch role). |
| `access_log_retention_days` | `number` | `14` | Retention of the access logs. |
| `tags` | `map(string)` | `{}` | Tags for the resources that support them. |

## Outputs

| Name | Description |
|------|-------------|
| `api_gateway_url` | `https://` URL of the custom domain. |
| `api_gateway_invoke_url` | Default execute-api URL of the stage. |
| `rest_api_id` | ID of the REST API. |
| `lambda_function_arn` | ARN of the function. |
| `lambda_function_name` | Name of the function. |
| `lambda_alias_arn` | ARN of the alias API Gateway invokes. |
| `lambda_role_name` | Execution role name, to attach extra policies. |
| `certificate_arn` | ARN of the ACM certificate. |
| `lambda` | The whole `modules/lambda` output. |

## Submodule `modules/lambda`

The function, alias, role and log group on their own, for functions without an API (e.g. an SQS consumer). Invoke `alias.arn`, not the function, to use provisioned concurrency.

## Requirements

- Terraform >= 1.5 (>= 1.9 to run the tests)
- AWS provider >= 6.26.0
- A public Route53 hosted zone for `top_level_domain`

## Development

```bash
./scripts/validate.sh   # fmt, validate (module, submodules, examples) and terraform test with a mocked provider
```

See [CHANGELOG.md](CHANGELOG.md) for upgrading from v1.

## License

This module is licensed under the MIT License.
