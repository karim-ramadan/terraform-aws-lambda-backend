output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function"
  value       = module.lambda.function.arn
}

output "lambda_function_name" {
  description = "The name of the deployed Lambda function"
  value       = module.lambda.function.function_name
}

output "lambda_alias_arn" {
  description = "The ARN of the alias API Gateway invokes"
  value       = module.lambda.alias.arn
}

output "lambda_role_name" {
  description = "Name of the function's execution role, to attach extra policies"
  value       = module.lambda.iam_role.name
}

output "api_gateway_url" {
  description = "The URL of the deployed API Gateway (custom domain)"
  value       = "https://${aws_api_gateway_domain_name.this.domain_name}"
}

output "api_gateway_invoke_url" {
  description = "The default execute-api URL of the stage"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "certificate_arn" {
  description = "The ARN of the generated SSL certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "lambda" {
  description = "The complete Lambda module output (for advanced usage)"
  value       = module.lambda
}
