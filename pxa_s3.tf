resource "aws_s3_bucket" "static" {
  bucket = "${local.pxa_prefix}-s3-static"
  tags = {
    Name        = "${local.pxa_prefix}-s3-static"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket              = aws_s3_bucket.static.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}