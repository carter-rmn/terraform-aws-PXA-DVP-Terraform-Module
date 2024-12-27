resource "aws_iam_openid_connect_provider" "eks_main" {
  count           = var.eks.create ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_main[count.index].certificates.0.sha1_fingerprint]
  url             = local.eks.oidc.url

  tags = {
    Name        = "${local.pxa_prefix}-oidcp"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
