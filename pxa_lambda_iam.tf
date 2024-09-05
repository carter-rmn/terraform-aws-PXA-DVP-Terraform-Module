resource "aws_iam_role" "lambda_role" {
  name = "${local.pxa_prefix}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "${local.pxa_prefix}-lambda-role"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "${local.pxa_prefix}-lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_vpc_access_execution" {
  name       = "${local.pxa_prefix}-lambda-vpc-access-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_secrets_manager_policy" {
  name        = "${local.pxa_prefix}-lambda-secrets-manager-policy"
  description = "Policy to allow Lambda functions to access Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource = "arn:aws:secretsmanager:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:secret:${local.pxa_prefix}-${var.PROJECT_ENV}-*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_secrets_manager_attachment" {
  name       = "${local.pxa_prefix}-lambda-secrets-manager-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_secrets_manager_policy.arn
}