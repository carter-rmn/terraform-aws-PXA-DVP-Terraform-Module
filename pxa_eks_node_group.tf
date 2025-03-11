resource "aws_launch_template" "eks_main_node_group" {
  for_each = var.eks.create ? { for key, group in var.eks.new.node_groups : key => group } : {}
  name     = "${local.pxa_prefix}-eks-main-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }

  instance_type = each.value.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.pxa_prefix}-eks-main-node"
      Project     = "${local.pxa_project_name}"
      Customer    = var.PROJECT_CUSTOMER
      Environment = var.PROJECT_ENV
      Terraform   = "true"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${local.pxa_prefix}-eks-main-node-volume"
      Project     = "${local.pxa_project_name}"
      Customer    = var.PROJECT_CUSTOMER
      Environment = var.PROJECT_ENV
      Terraform   = "true"
    }
  }

  tags = {
    Name        = "${local.pxa_prefix}-eks-main-launch-template"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = "true"
  }
}

resource "aws_eks_node_group" "eks_main" {
  for_each        = var.eks.create ? { for key, group in var.eks.new.node_groups : key => group } : {}
  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = "${local.pxa_prefix}-eks-node-group-main"
  node_role_arn   = aws_iam_role.eks_main_node_group[0].arn
  subnet_ids      = var.vpc.subnets.private

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_main_node_group[each.key].id
    version = aws_launch_template.eks_main_node_group[each.key].latest_version
  }

  labels = {
    "nodegroup" = "${local.pxa_prefix}-node-group"
  }

  tags = {
    Name        = "${local.pxa_prefix}-eks-node-group-main"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = "true"
  }
}
