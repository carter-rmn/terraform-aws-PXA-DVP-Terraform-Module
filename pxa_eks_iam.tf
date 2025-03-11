resource "aws_iam_role" "eks_main" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-iam-role-eks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-iam-role-eks"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_main[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_vpc" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_main[count.index].name
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_main[count.index].name
}
