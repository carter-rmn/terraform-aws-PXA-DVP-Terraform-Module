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

data "tls_certificate" "eks" {
  count = var.eks.create ? 1 : 0
  url   = local.eks_oidc_url
}

data "aws_eks_cluster_auth" "eks" {
  count        = var.eks.create ? 1 : 0
  name         = aws_eks_cluster.eks[count.index].name
}

provider "kubernetes" {
  host                   = local.kubernetes_config != null ? local.kubernetes_config.host : null
  cluster_ca_certificate = local.kubernetes_config != null ? local.kubernetes_config.cluster_ca_certificate : null
  token                  = local.kubernetes_config != null ? local.kubernetes_config.token : null
}

# Get existing aws-auth ConfigMap
data "kubernetes_config_map" "aws_auth" {
  count = var.eks.create ? 1 : 0
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

# Update aws-auth ConfigMap
resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = var.eks.create ? 1 : 0
  force = true
  
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = lookup(data.kubernetes_config_map.aws_auth[0].data, "mapRoles", "")
    mapUsers = replace(yamlencode(distinct(concat(
      yamldecode(lookup(data.kubernetes_config_map.aws_auth[0].data, "mapUsers", "[]")),
      yamldecode(local.eks_auth_users)
    ))), "\"", "")
  }

  depends_on = [aws_eks_cluster.eks]
}