resource "aws_iam_user" "app_user" {
  name = "${local.pxa_prefix}-user-app"
  tags = {
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_access_key" "app_user" {
  user = aws_iam_user.app_user.name
}

resource "aws_iam_service_specific_credential" "keyspaces_app_user_credential" {
  user_name    = aws_iam_user.app_user.name
  service_name = "cassandra.amazonaws.com"
}

resource "aws_iam_user_policy" "app_user" {
  name = "${local.pxa_prefix}-policy-app-user"
  user = aws_iam_user.app_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.static.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.static.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Modify",
          "cassandra:Create",
          "cassandra:Alter",
          "cassandra:Drop",
          "cassandra:Describe",
          "cassandra:Execute"
        ]
        Resource = [
          "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/system*",
          "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/${aws_keyspaces_keyspace.carter_analytics.name}/table/*"
        ]
      },
      {
        Sid    = "ListVPCEndpoints"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcEndpoints"
        ]
        Resource = "*"
      }
    ]
  })
}
