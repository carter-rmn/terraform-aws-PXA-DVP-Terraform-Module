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

resource "aws_launch_template" "eks_node_group" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-eks-node-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }

  instance_type = var.eks.eks_node_group.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.pxa_prefix}-eks-node"
      Project     = "${local.pxa_project_name}"
      Customer    = var.PROJECT_CUSTOMER
      Environment = var.PROJECT_ENV
      Terraform   = "true"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${local.pxa_prefix}-eks-node-volume"
      Project     = "${local.pxa_project_name}"
      Customer    = var.PROJECT_CUSTOMER
      Environment = var.PROJECT_ENV
      Terraform   = "true"
    }
  }

  tags = {
    Name        = "${local.pxa_prefix}-eks-node-launch-template"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = "true"
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

  launch_template {
    id      = aws_launch_template.eks_node_group[count.index].id
    version = aws_launch_template.eks_node_group[count.index].latest_version
  }

  labels = {
    "nodegroup" = "${local.pxa_prefix}-node-group"
  }

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

# VPC CNI Addon
resource "aws_eks_addon" "vpc_cni" {
  count                    = var.eks.create ? 1 : 0
  cluster_name             = aws_eks_cluster.eks[count.index].name
  addon_name               = "vpc-cni"
  addon_version            = "v1.18.6-eksbuild.1"
  service_account_role_arn = aws_iam_role.vpc_cni[count.index].arn

  configuration_values = jsonencode({
    "env": {
      # IP Address Configuration
      "WARM_IP_TARGET"               = "7"
      "WARM_ENI_TARGET"              = "1"
      "MINIMUM_IP_TARGET"            = "7"
      "ENABLE_PREFIX_DELEGATION"     = "true"
      
    }
  })

  depends_on = [
    aws_iam_role_policy_attachment.vpc_cni
  ]

  tags = {
    Name        = "${local.pxa_prefix}-vpc-cni-addon"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Fetch Latest EBS CSI Driver Version
data "aws_eks_addon_version" "ebs_csi" {
  count = var.eks.create ? 1 : 0
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = "1.29"
  most_recent        = true
}

# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  count                    = var.eks.create ? 1 : 0
  cluster_name             = aws_eks_cluster.eks[count.index].name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi[count.index].version
  service_account_role_arn = aws_iam_role.ebs_csi_driver[count.index].arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver
  ]

  tags = {
    Name        = "${local.pxa_prefix}-ebs-csi-driver-addon"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

data "aws_eks_cluster_auth" "eks" {
  count        = var.eks.create ? 1 : 0
  name         = aws_eks_cluster.eks[count.index].name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks[count.index].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks[count.index].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks[count.index].token
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

  lifecycle {
    ignore_changes = []
    prevent_destroy = true
  }

  depends_on = [aws_eks_cluster.eks]
}