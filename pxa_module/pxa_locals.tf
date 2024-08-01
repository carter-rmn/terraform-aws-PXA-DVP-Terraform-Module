locals {
  pxa_project_name = "pxa"
  pxa_prefix       = "${local.pxa_project_name}-${var.PROJECT_CUSTOMER}-${var.PROJECT_ENV}"
  pxa_config       = jsondecode(data.local_file.pxa_config.content)

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
