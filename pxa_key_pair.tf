resource "tls_private_key" "ec2s" {
  for_each  = local.keys
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2s" {
  for_each   = local.keys
  key_name   = "${local.pxa_prefix}-ec2-${each.key}"
  public_key = tls_private_key.ec2s[each.key].public_key_openssh
  depends_on = [aws_secretsmanager_secret.pxa_secret_ec2s]

  tags = {
    Name        = "${local.pxa_prefix}-ec2-${each.key}"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}