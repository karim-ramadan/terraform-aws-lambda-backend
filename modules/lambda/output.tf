output "iam_role" {
  description = "The IAM role used by the Lambda function for execution"
  value       = aws_iam_role.lambda_execution_role
}

output "function" {
  description = "The Lambda function resource"
  value       = aws_lambda_function.this
}