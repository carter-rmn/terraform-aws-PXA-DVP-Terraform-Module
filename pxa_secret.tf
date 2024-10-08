resource "aws_secretsmanager_secret" "pxa_secret_terraform" {
  name = "${local.pxa_prefix}-secret-terraform"
  tags = {
    Name        = "${local.pxa_prefix}-secret-terraform"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret" "pxa_secret_ec2s" {
  for_each = local.keys
  name     = "${local.pxa_prefix}-secret-key-${each.key}"

  tags = {
    Name        = "${local.pxa_prefix}-secret-key-${each.key}"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
