resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${local.pxa_prefix}-s3-resources"
  tags = {
    Name        = "${local.pxa_prefix}-s3-resources"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket              = aws_s3_bucket.s3_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "s3_user" {
  name = "${local.pxa_prefix}-s3-user"
  tags = {
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name = "${local.pxa_prefix}-policy-s3-app-user"
  user = aws_iam_user.s3_user.name

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
          aws_s3_bucket.s3_bucket.arn
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
          "${aws_s3_bucket.s3_bucket.arn}/*"
        ]
      }
    ]
  })
}