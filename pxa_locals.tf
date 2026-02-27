locals {
  pxa_project_name = "${var.PROJECT_PRENAME}pxa"
  pxa_prefix       = "${local.pxa_project_name}-${var.PROJECT_CUSTOMER}-${var.PROJECT_ENV}"

  // ************************************* Inputs

  ec2 = {
    security_groups : {
      "ansible" : aws_security_group.ansible.id
      "bastion" : aws_security_group.bastion.id
      "cicd" : aws_security_group.cicd.id
      "mongo" : aws_security_group.mongo.id
      "dataflows" : aws_security_group.dataflows.id
      #"openvpn" : aws_security_group.openvpn.id
    }
  }

  users = {
    "app"    = { policy = { action = [] } }
    "static" = { policy = { action = [] } }
  }

  s3s = {
    static = { publicly_readable = false, users = ["static"] }
  }

  databases = {
    mongo = {
      port = 27017
      pxa = {
        name = "carter-analytics"
        users = {
          root   = "root"
          admin  = "admin"
          app    = "carter_analytics"
          viewer = "viewer"
        }
      }
    }
  }

  // ************************************* Computes
  keys = { for item in distinct([for item, _ in var.ec2.instances : element(split("-", item), 0)]) : item => {} }

  eks = {
    oidc = {
      url = var.eks.create ? aws_eks_cluster.main[0].identity[0].oidc[0].issuer : var.eks.existing.openid_connect.issuer
      arn = var.eks.create ? aws_iam_openid_connect_provider.eks_main[0].arn : var.eks.existing.openid_connect.arn
    }
  }

  msk = { bootstrap_brokers = var.msk.create ? aws_msk_cluster.main[0].bootstrap_brokers : var.msk.existing.bootstrap_brokers }

  s3_users = flatten(
    [
      for name, s3 in local.s3s : [
        for user in s3.users : {
          name = name
          s3   = s3
          user = user
        }
      ]
    ]
  )

  pod_identity_apps = merge(
    {
      "app" = { role_key = "app" }
      "static" = { role_key = "static" }

    }
  )

  app_roles_eks = {
    for user, config in local.users : user => config
    if var.pod_identity.enabled
  }

  app_roles_s3 = flatten([
    for name, config in local.s3s : [
      for user in config.users : {
        name   = name
        user   = user
        config = config
      }
      if contains(keys(local.app_roles_eks), user) # Only create if corresponding app_role exists
    ]
  ])
}
