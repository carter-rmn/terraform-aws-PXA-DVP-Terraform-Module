resource "aws_ecr_repository" "ecrs" {
  count                = length(local.ecr.names)
  name                 = "${local.pxa_prefix}-ecr-${local.ecr.names[count.index]}"
  image_tag_mutability = local.ecr.imagetag

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${local.pxa_prefix}-ecr-${local.ecr.names[count.index]}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
