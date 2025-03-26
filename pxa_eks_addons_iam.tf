# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_main[count.index].arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-ebs-csi-driver-role"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Attach AWS-managed EBS CSI Driver Policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver[count.index].name
}

# IAM Role for EFS CSI Driver
resource "aws_iam_role" "efs_csi_driver" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_main[count.index].arn
        }
        Condition = {
          StringLike = {
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:efs-csi-*",
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-efs-csi-driver-role"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Attach AWS-managed EFS CSI Driver Policy
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver[count.index].name
}


# IAM Policy for S3 CSI Driver
resource "aws_iam_policy" "mountpoint_s3_csi_driver" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-iam-policy-mountpoint-s3-csi-driver"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
        {
            "Sid": "MountpointFullBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::amzn-s3-eks-demo-bucket"
            ]
        },
        {
            "Sid": "MountpointFullObjectAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::amzn-s3-eks-demo-bucket/*"
            ]
        }
   ]
}
EOF
  tags = {
    Name        = "${local.pxa_prefix}-iam-policy-mountpoint-s3-csi-driver"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# IAM Role for S3 CSI Driver
resource "aws_iam_role" "mountpoint_s3_csi_driver" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-mountpoint-s3-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_main[count.index].arn
        }
        Condition = {
          StringLike = {
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:s3-csi-driver-sa",
            "${replace(aws_eks_cluster.main[count.index].identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-mountpoint-s3-csi-driver-role"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Attach AWS-managed S3 CSI Driver Policy
resource "aws_iam_role_policy_attachment" "mountpoint_s3_csi_driver" {
  count      = var.eks.create ? 1 : 0
  policy_arn = aws_iam_policy.mountpoint_s3_csi_driver[count.index].arn
  role       = aws_iam_role.mountpoint_s3_csi_driver[count.index].name
}
