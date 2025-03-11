resource "aws_iam_role" "eks_main_node_group" {
  count = var.eks.create ? 1 : 0
  name  = "${local.pxa_prefix}-iam-role-eks-node"

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

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_log" {
  count      = var.eks.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_policy" "s3_access" {
  count       = var.eks.create ? 1 : 0
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

resource "aws_iam_role_policy_attachment" "s3_access" {
  count      = var.eks.create ? 1 : 0
  policy_arn = aws_iam_policy.s3_access[count.index].arn
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_policy" "secrets_manager_read" {
  count       = var.eks.create ? 1 : 0
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
        Resource = "arn:aws:secretsmanager:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:secret:${local.pxa_prefix}-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_read" {
  count      = var.eks.create ? 1 : 0
  policy_arn = aws_iam_policy.secrets_manager_read[count.index].arn
  role       = aws_iam_role.eks_main_node_group[count.index].name
}

resource "aws_iam_policy" "keyspaces_access" {
  count       = var.eks.create ? 1 : 0
  name        = "${local.pxa_prefix}-keyspaces-access-policy"
  description = "Policy to allow access to the Keyspaces for the project"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cassandra:Select",
          "cassandra:Modify",
          "cassandra:Create",
          "cassandra:Alter",
          "cassandra:Drop",
          "cassandra:Describe",
          "cassandra:Execute"
        ],
        Resource = [
          "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/system*",
          "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/${aws_keyspaces_keyspace.carter_analytics.name}/table/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "keyspaces_access" {
  count      = var.eks.create ? 1 : 0
  policy_arn = aws_iam_policy.keyspaces_access[count.index].arn
  role       = aws_iam_role.eks_main_node_group[count.index].name
}
