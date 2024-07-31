resource "aws_s3_bucket" "bucket" {
  bucket = "${local.pxa_project_name}-${var.PROJECT_ENV}-carter-analytics-bucket"

  tags = {
    Name        = "${local.pxa_project_name}-${var.PROJECT_ENV}-carter-analytics-bucket"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
