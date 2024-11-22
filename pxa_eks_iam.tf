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

# IAM Role for VPC CNI
resource "aws_iam_role" "vpc_cni" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks[count.index].arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-node",
            "${replace(aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-vpc-cni-role"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Attach VPC CNI Policy
resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni[count.index].name
}

resource "aws_iam_role_policy" "vpc_cni_custom" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-vpc-cni-custom-policy"
  role  = aws_iam_role.vpc_cni[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AssignPrivateIpAddresses",
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

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
          Federated = aws_iam_openid_connect_provider.eks[count.index].arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(aws_eks_cluster.eks[count.index].identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com"
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