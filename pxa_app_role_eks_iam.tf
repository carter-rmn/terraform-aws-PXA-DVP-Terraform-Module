# IAM Roles for Application Services using Pod Identity
# This file creates IAM roles that can be assumed by EKS pods via Pod Identity

# Data source for assume role policy document for Pod Identity
data "aws_iam_policy_document" "pod_identity_assume_role" {
  for_each = local.app_roles_eks

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

# Create IAM roles for applications
resource "aws_iam_role" "app_role_eks" {
  for_each = local.app_roles_eks

  name               = "${local.pxa_prefix}-iam-role-app-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role[each.key].json

  tags = {
    Name        = "${local.pxa_prefix}-iam-role-app-${each.key}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Create custom policies for application roles (if they have specific actions defined)
resource "aws_iam_policy" "app_role_policies" {
  for_each = {
    for name, config in local.app_roles_eks : name => config if length(config) > 0
  }

  name        = "${local.pxa_prefix}-iam-policy-app-${each.key}"
  description = "Custom policy for ${each.key} application role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      for policy_name, policy_config in each.value : [
        {
          Effect   = policy_config.effect
          Action   = policy_config.actions
          Resource = policy_config.resource
        }
      ]
    ])
  })

  tags = {
    Name        = "${local.pxa_prefix}-iam-policy-app-${each.key}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# Attach custom policies to roles
resource "aws_iam_role_policy_attachment" "app_role_custom_policies" {
  for_each = {
    for name, config in local.app_roles_eks : name => config if length(config) > 0
  }

  role       = aws_iam_role.app_role_eks[each.key].name
  policy_arn = aws_iam_policy.app_role_policies[each.key].arn
}