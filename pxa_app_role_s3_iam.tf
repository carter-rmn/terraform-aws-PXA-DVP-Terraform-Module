resource "aws_iam_policy" "app_role_s3" {
  for_each = {
    for item in local.app_roles_s3 : "${item.name}-${item.user}" => item if contains(keys(local.app_roles_eks), item.user)
  }

  name        = "${local.pxa_prefix}-iam-policy-s3-app-role-${each.value.name}-${each.value.user}-policy"
  description = "S3 access policy for ${each.value.user} role to ${each.value.name} bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.s3s[each.value.name].arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.s3s[each.value.name].arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${local.pxa_prefix}-iam-policy-s3-app-role-${each.value.name}-${each.value.user}-policy"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "app_role_s3" {
  for_each = {
    for item in local.app_roles_s3 : "${item.name}-${item.user}" => item if contains(keys(local.app_roles_eks), item.user)
  }

  role       = aws_iam_role.app_role_eks[each.value.user].name
  policy_arn = aws_iam_policy.app_role_s3[each.key].arn
}