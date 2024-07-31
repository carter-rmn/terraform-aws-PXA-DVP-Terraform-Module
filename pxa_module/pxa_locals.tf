locals {
  pxa_project_name = "pxa"
  pxa_prefix       = "${local.pxa_project_name}-${var.PROJECT_CUSTOMER}-${var.PROJECT_ENV}"
  pxa_config       = jsondecode(data.local_file.pxa_config.content)

  vpc = {
    id = local.pxa_config.vpc.create ? module.vpc[0].vpc_id : local.pxa_config.vpc.existing.id
    default_security_group = {
      id = local.pxa_config.vpc.create ? module.vpc[0].default_security_group_id : local.pxa_config.vpc.existing.default_security_group_id
    }
    subnets = {
      public   = local.pxa_config.vpc.create ? module.vpc[0].public_subnets : local.pxa_config.vpc.existing.subnet_ids.public
      private  = local.pxa_config.vpc.create ? module.vpc[0].private_subnets : local.pxa_config.vpc.existing.subnet_ids.private
      database = local.pxa_config.vpc.create ? module.vpc[0].database_subnets : local.pxa_config.vpc.existing.subnet_ids.database
    }
    cidr_blocks = {
      public   = local.pxa_config.vpc.create ? local.pxa_config.vpc.new.subnets.public : local.pxa_config.vpc.existing.cidr_blocks.public
      private  = local.pxa_config.vpc.create ? local.pxa_config.vpc.new.subnets.private : local.pxa_config.vpc.existing.cidr_blocks.private
      database = local.pxa_config.vpc.create ? local.pxa_config.vpc.new.subnets.database : local.pxa_config.vpc.existing.cidr_blocks.database
    }
  }
  ec2 = {
    security_groups : {
      "bastion" : aws_security_group.sg_bastion.id
      "cicd" : aws_security_group.sg_cicd.id
      "mongo" : aws_security_group.sg_mongo.id
    }
  }
  ecr = {
    names = [
      "carter-analytics-api",
      "analytics-dashboard",
      "kafka-connector"
    ]
    "imagetag" : "IMMUTABLE"
  }
}
