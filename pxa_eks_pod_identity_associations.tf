resource "aws_eks_pod_identity_association" "apps" {
  for_each = var.pod_identity.enabled ? { for name, config in local.pod_identity_apps : name => config } : {}

  cluster_name    = var.eks.create ? aws_eks_cluster.main[0].name : var.eks.existing.name
  namespace       = var.PROJECT_ENV
  service_account = "${local.pxa_prefix}-${each.key}"
  role_arn        = aws_iam_role.app_role_eks[each.value.role_key].arn

  tags = {
    Name = "${local.pxa_prefix}-pod-identity-${each.key}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}