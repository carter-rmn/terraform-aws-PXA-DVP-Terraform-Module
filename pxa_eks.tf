resource "aws_eks_cluster" "eks" {
  count                     = var.eks.create ? 1 : 0
  name                      = "${local.pxa_prefix}-eks-cluster"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn                  = aws_iam_role.role_eks[count.index].arn
  version                   = "1.29"

  vpc_config {
    endpoint_public_access = true
    subnet_ids             = var.vpc.subnets.private
  }

  tags = {
    Name        = "${local.pxa_prefix}-eks"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  count           = var.eks.create ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[count.index].name
  node_group_name = "${local.pxa_prefix}-eks-node-group"
  node_role_arn   = aws_iam_role.role_eks_node[count.index].arn
  subnet_ids      = var.vpc.subnets.private

  scaling_config {
    desired_size = var.eks.eks_node_group.desired_size
    max_size     = var.eks.eks_node_group.max_size
    min_size     = var.eks.eks_node_group.min_size
  }

  instance_types = [var.eks.eks_node_group.instance_type]

  tags = {
    Name        = "${local.pxa_prefix}-eks-node-group"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = "true"
  }
}

data "tls_certificate" "eks" {
  count = var.eks.create ? 1 : 0
  url   = local.eks_oidc_url
}