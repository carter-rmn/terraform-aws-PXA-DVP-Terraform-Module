resource "aws_secretsmanager_secret_version" "pxa_secret_terraform" {
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
    keyspace = {
      name = aws_keyspaces_keyspace.carter_analytics.name
    }
    app_user = {
      access_key = aws_iam_access_key.user_keys["app"].id
      secret_key = aws_iam_access_key.user_keys["app"].secret
      keyspaces = {
        service_specific_credential_id = aws_iam_service_specific_credential.keyspaces_app_user.service_specific_credential_id
        service_specific_credential    = aws_iam_service_specific_credential.keyspaces_app_user.service_password
        username                       = aws_iam_service_specific_credential.keyspaces_app_user.service_user_name
      }
    }
    mongo = {
      pxa = {
        name        = local.databases.mongo.pxa.name
        port        = local.databases.mongo.port
        private_ip  = aws_instance.ec2s["mongo-pxa-1"].private_ip
        private_dns = aws_instance.ec2s["mongo-pxa-1"].private_dns
        public_dns  = aws_instance.ec2s["mongo-pxa-1"].public_dns
        public_ip   = aws_instance.ec2s["mongo-pxa-1"].public_ip
        users = {
          for user, username in local.databases.mongo.pxa.users : user => {
            username          = username
            password          = random_password.mongo["pxa_mongo_${user}"].result
            connection_string = "mongodb://${username}:${random_password.mongo["pxa_mongo_${user}"].result}@${join(",", [for item in aws_instance.ec2s : "${item.private_ip}:${local.databases.mongo.port}" if length(regexall("(mongo-pxa-\\d+)", item.tags.Short)) > 0])}/${local.databases.mongo.pxa.name}?authSource=admin${length([for item in aws_instance.ec2s : 1 if length(regexall("(mongo-pxa-\\d+)", item.tags.Short)) > 0]) > 1 ? "&replicaSet=rmn" : ""}"
          }
        }
      }
    }
    ecr = {
      domain = element(split("/", aws_ecr_repository.ecrs["api"].repository_url), 0)
    }
    eks = {
      created = var.eks.create
      name    = var.eks.create ? "${local.pxa_prefix}-eks" : var.eks.existing.name
      roles = {
        lb_contorller = {
          arn = var.eks.create ? aws_iam_role.lb_controller[0].arn : var.eks.existing.lb_contorller_arn
        }
      }
    }
    msk = {
      address = substr(element(split(":", element(split(",", local.msk.bootstrap_brokers), 0)), 0), 4, -1)
      port    = element(split(":", element(split(",", local.msk.bootstrap_brokers), 0)), 1)
      url     = substr(element(split(",", local.msk.bootstrap_brokers), 0), 4, -1)
    }
    lambda = {
      name = aws_lambda_function.event.function_name
    }
    s3s = {
      for key, value in local.s3s :
      key => {
        name   = aws_s3_bucket.s3s[key].bucket
        domain = aws_s3_bucket.s3s[key].bucket_domain_name
      }
    }
  })
}

resource "aws_secretsmanager_secret_version" "pxa_secret_ec2s" {
  for_each      = local.keys
  secret_id     = aws_secretsmanager_secret.ec2s[each.key].id
  secret_string = tls_private_key.ec2s[each.key].private_key_pem
}
