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