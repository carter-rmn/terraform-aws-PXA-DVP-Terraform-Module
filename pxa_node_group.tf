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