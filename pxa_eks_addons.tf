# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  count                    = var.eks.create ? 1 : 0
  cluster_name             = aws_eks_cluster.main[count.index].name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.37.0-eksbuild.1"
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

# EFS CSI Driver Addon
resource "aws_eks_addon" "efs_csi_driver" {
  count                    = var.eks.create ? 1 : 0
  cluster_name             = aws_eks_cluster.main[count.index].name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = "v2.1.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.efs_csi_driver[count.index].arn

  depends_on = [
    aws_iam_role_policy_attachment.efs_csi_driver
  ]

  tags = {
    Name        = "${local.pxa_prefix}-efs-csi-driver-addon"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# S3 CSI Driver Addon
resource "aws_eks_addon" "mountpoint_s3_csi_driver" {
  count                    = var.eks.create ? 1 : 0
  cluster_name             = aws_eks_cluster.main[count.index].name
  addon_name               = "aws-mountpoint-s3-csi-driver"
  addon_version            = "v1.10.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.mountpoint_s3_csi_driver[count.index].arn

  depends_on = [
    aws_iam_role_policy_attachment.mountpoint_s3_csi_driver
  ]

  tags = {
    Name        = "${local.pxa_prefix}-mountpoint-s3-csi-driver-addon"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
