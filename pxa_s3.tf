resource "aws_s3_bucket" "s3s" {
  for_each = local.s3s
  bucket   = "${local.pxa_prefix}-s3-${each.key}"
  tags = {
    Name        = "${local.pxa_prefix}-s3-${each.key}"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3s" {
  for_each                = local.s3s
  bucket                  = aws_s3_bucket.s3s[each.key].id
  block_public_acls       = !each.value.publicly_readable
  block_public_policy     = !each.value.publicly_readable
  ignore_public_acls      = !each.value.publicly_readable
  restrict_public_buckets = !each.value.publicly_readable
}
