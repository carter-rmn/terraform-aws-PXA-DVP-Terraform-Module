resource "aws_secretsmanager_secret_version" "pxa_secret_terraform" {
  secret_id = aws_secretsmanager_secret.pxa_secret_terraform.id
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
      access_key = aws_iam_access_key.app_user_key.id
      secret_key = aws_iam_access_key.app_user_key.secret
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
          root = {
            username = local.databases.mongo.pxa.usernames.root
            password = random_password.mongo_pxa_root_password.result
          }
          app = {
            username          = local.databases.mongo.pxa.usernames.app
            password          = random_password.mongo_pxa_app_password.result
            connection_string = "mongodb://${local.databases.mongo.pxa.usernames.app}:${random_password.mongo_pxa_app_password.result}@${join(",", [for item in aws_instance.ec2s : "${item.private_ip}:${local.databases.mongo.port}" if length(regexall("(mongo-ad-platform-\\d+)", item.tags.Short)) > 0])}/${local.databases.mongo.pxa.name}?authSource=admin${length([for item in aws_instance.ec2s : 1 if length(regexall("(mongo-ad-platform-\\d+)", item.tags.Short)) > 0]) > 1 ? "&replicaSet=rmn" : ""}"
          }
          viewer = {
            username          = local.databases.mongo.pxa.usernames.viewer
            password          = random_password.mongo_pxa_viewer_password.result
            connection_string = "mongodb://${local.databases.mongo.pxa.usernames.viewer}:${random_password.mongo_pxa_viewer_password.result}@${join(",", [for item in aws_instance.ec2s : "${item.private_ip}:${local.databases.mongo.port}" if length(regexall("(mongo-ad-platform-\\d+)", item.tags.Short)) > 0])}/${local.databases.mongo.pxa.name}?authSource=admin${length([for item in aws_instance.ec2s : 1 if length(regexall("(mongo-ad-platform-\\d+)", item.tags.Short)) > 0]) > 1 ? "&replicaSet=rmn" : ""}"
          }
        }
      }
    }
    eks = {
      roles = {
        lb_contorller = {
          arn = var.eks.create ? aws_iam_role.role_role_lb_controller[0].arn : null
        }
      }
    }
  })
}

resource "aws_secretsmanager_secret_version" "pxa_secret_ec2s" {
  for_each      = local.keys
  secret_id     = aws_secretsmanager_secret.pxa_secret_ec2s[each.key].id
  secret_string = tls_private_key.ec2s[each.key].private_key_pem
}
