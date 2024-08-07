resource "aws_iam_openid_connect_provider" "eks" {
  count           = var.eks.create ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[count.index].certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.eks[count.index].identity.0.oidc.0.issuer

  tags = {
    Name        = "${local.pxa_prefix}-oidcp"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_role" "role_eks" {
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

resource "aws_iam_role_policy_attachment" "attachment_eks_cluster" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role_eks[count.index].name
}

resource "aws_iam_role_policy_attachment" "attachment_eks_vpc" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.role_eks[count.index].name
}

resource "aws_iam_role_policy_attachment" "attachment_ecr_access" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_eks[count.index].name
}