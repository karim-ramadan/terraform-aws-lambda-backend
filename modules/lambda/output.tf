output "iam_role" {
  value = aws_iam_role.lambda_execution_role
}

output "function" {
  value = aws_lambda_function.this
}