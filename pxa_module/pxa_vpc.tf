module "vpc" {
  count = local.pxa_config.vpc.create ? 1 : 0

  source = "terraform-aws-modules/vpc/aws"

  name = "${local.pxa_prefix}-vpc"
  cidr = local.pxa_config.vpc.new.cidr

  manage_default_security_group = true
  default_security_group_name   = "${local.pxa_prefix}-sg-default"

  azs              = local.pxa_config.vpc.new.azs
  private_subnets  = local.pxa_config.vpc.new.subnets.private
  public_subnets   = local.pxa_config.vpc.new.subnets.public
  database_subnets = local.pxa_config.vpc.new.subnets.database

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_vpn_gateway     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true

  default_security_group_ingress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      self      = true
    }
  ]
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "${local.pxa_prefix}-vpc"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
