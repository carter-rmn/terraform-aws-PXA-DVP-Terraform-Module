resource "aws_iam_role" "role_eks_node" {
  name = "${local.pxa_prefix}-iam-role-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-iam-role-eks-node"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "attachment_eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_eks_node.name
}

resource "aws_iam_role_policy_attachment" "attachment_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_eks_node.name
}

resource "aws_iam_role_policy_attachment" "attachment_ec2_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_eks_node.name
}

resource "aws_iam_role_policy_attachment" "attachment_cloudwatch_log" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.role_eks_node.name
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${local.pxa_prefix}-s3-access-policy"
  description = "Policy to allow access to the S3 bucket created for the project"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${local.pxa_project_name}-${var.PROJECT_ENV}-bucket",
          "arn:aws:s3:::${local.pxa_project_name}-${var.PROJECT_ENV}-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment_s3_access" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.role_eks_node.name
}

resource "aws_iam_policy" "secrets_manager_read_policy" {
  name        = "${local.pxa_prefix}-secrets-manager-read-policy"
  description = "Policy to allow read access to Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource = "arn:aws:secretsmanager:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:secret:${local.pxa_project_name}-${var.PROJECT_ENV}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment_secrets_manager_read" {
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
  role       = aws_iam_role.role_eks_node.name
}