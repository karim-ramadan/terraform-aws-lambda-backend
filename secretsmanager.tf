#Get existing secret
data "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}

#Create policy to read the secret
resource "aws_iam_policy" "secrets_manager_read" {
  name        = "${var.application_name}-secretsmanager-policy"
  description = "Policy to allow reading a secret from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = data.aws_secretsmanager_secret.this.arn
      }
    ]
  })
}

#Attach the policy to the lambda function
resource "aws_iam_role_policy_attachment" "lambda_exec_role_policy_attachment" {
  role       = module.lambda.iam_role.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}