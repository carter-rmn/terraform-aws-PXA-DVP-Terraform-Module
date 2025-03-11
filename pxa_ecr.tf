resource "aws_ecr_repository" "ecrs" {
  for_each             = local.ecr
  name                 = "${local.pxa_prefix}-ecr-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${local.pxa_prefix}-ecr-${each.key}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  for_each   = local.ecr
  repository = "${local.pxa_prefix}-ecr-${each.key}"
  policy     = data.aws_ecr_lifecycle_policy_document.ecr_lifecycle.json
  depends_on = [aws_ecr_repository.ecrs]
}
