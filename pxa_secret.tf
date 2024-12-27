resource "aws_secretsmanager_secret" "terraform" {
  name = "${local.pxa_prefix}-secret-terraform"
  tags = {
    Name        = "${local.pxa_prefix}-secret-terraform"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret" "ec2s" {
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

resource "aws_secretsmanager_secret" "kafka_connector" {
  name = "${local.pxa_prefix}-secret-kafka-connector"
  tags = {
    Name        = "${local.pxa_prefix}-secret-kafka-connector"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret" "api" {
  name = "${local.pxa_prefix}-secret-api"
  tags = {
    Name        = "${local.pxa_prefix}-secret-api"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret" "kestra" {
  name = "${local.pxa_prefix}-secret-kestra"
  tags = {
    Name        = "${local.pxa_prefix}-secret-kestra"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
