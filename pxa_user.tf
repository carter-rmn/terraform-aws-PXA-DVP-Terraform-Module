resource "aws_iam_user" "users" {
  for_each = local.users
  name     = "${local.pxa_prefix}-user-app-${each.key}"

  tags = {
    Name        = "${local.pxa_prefix}-user-app-${each.key}"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_access_key" "user_keys" {
  for_each   = aws_iam_user.users
  user       = "${local.pxa_prefix}-user-app-${each.key}"
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_service_specific_credential" "keyspaces_app_user_credential" {
  user_name    = aws_iam_user.app_user.name
  service_name = "cassandra.amazonaws.com"
}
