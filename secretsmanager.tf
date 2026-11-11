# Lets the function read the given secrets. ARNs (not names) so the secrets can be
# created in the same apply as the module
resource "aws_iam_role_policy" "secrets_manager_read" {
  count = length(var.secret_arns) > 0 ? 1 : 0

  name = "secretsmanager-read"
  role = module.lambda.iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secret_arns
      }
    ]
  })
}
