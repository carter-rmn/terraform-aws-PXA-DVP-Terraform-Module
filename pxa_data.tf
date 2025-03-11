data "aws_caller_identity" "current" {}

data "tls_certificate" "eks_main" {
  count = var.eks.create ? 1 : 0
  url   = aws_eks_cluster.main[0].identity[0].oidc[0].issuer
}

data "aws_ecr_lifecycle_policy_document" "ecr_lifecycle" {
  rule {
    priority    = 1
    description = "Keep only the latest 5 images"

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = 5
    }

    action {
      type = "expire"
    }
  }
}

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_vpc_access_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
