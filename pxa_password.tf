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

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.terraform.id
  secret_string = jsonencode({
    aws = {
      region = var.AWS_REGION
    }
    vpc = {
      id = var.vpc.id
      subnets = {
        private  = join(",", var.vpc.subnets.private)
        database = join(",", var.vpc.subnets.database)
        public   = join(",", var.vpc.subnets.public)
      }
    }
    msk = {
      address = substr(element(split(":", element(split(",", aws_msk_cluster.msk.bootstrap_brokers), 0)), 0), 4, -1)
      port    = element(split(":", element(split(",", aws_msk_cluster.msk.bootstrap_brokers), 0)), 1)
      url     = substr(element(split(",", aws_msk_cluster.msk.bootstrap_brokers), 0), 4, -1)
    }
    keyspace = {
      name = aws_keyspaces_keyspace.keyspace.name
    }
    s3_user = {
      access_key = aws_iam_access_key.s3_user_key.id
      secret_key = aws_iam_access_key.s3_user_key.secret
    }
  })
}
