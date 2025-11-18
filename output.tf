output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function"
  value       = module.lambda.function.arn
}

output "lambda_function_name" {
  description = "The name of the deployed Lambda function"
  value       = module.lambda.function.function_name
}

output "api_gateway_url" {
  description = "The URL of the deployed API Gateway (custom domain)"
  value       = "https://${aws_apigatewayv2_domain_name.this.domain_name}"
}

output "certificate_arn" {
  description = "The ARN of the generated SSL certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "lambda" {
  description = "The complete Lambda module output (for advanced usage)"
  value       = module.lambda
}