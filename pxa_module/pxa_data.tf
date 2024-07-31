data "local_file" "pxa_config" {
  filename = "./config/${local.pxa_prefix}-terraform-config.json"
}

data "aws_caller_identity" "current" {}