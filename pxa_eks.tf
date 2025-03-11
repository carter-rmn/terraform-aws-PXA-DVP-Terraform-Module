resource "aws_eks_cluster" "main" {
  count                     = var.eks.create ? 1 : 0
  name                      = "${local.pxa_prefix}-eks-main"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn                  = aws_iam_role.eks_main[count.index].arn
  version                   = "1.29"

  vpc_config {
    endpoint_public_access = true
    subnet_ids             = var.vpc.subnets.private
  }

  tags = {
    Name        = "${local.pxa_prefix}-eks-main"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# data "aws_eks_cluster_auth" "eks" {
#   count        = var.eks.create ? 1 : 0
#   name         = aws_eks_cluster.main[count.index].name
# }

# provider "kubernetes" {
#   host                   = aws_eks_cluster.main[0].endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.main[0].certificate_authority[0].data)
#   token                  =  data.aws_eks_cluster_auth.eks[0].token
# }
