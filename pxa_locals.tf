locals {
  pxa_project_name = "${var.PROJECT_PRENAME}pxa"
  pxa_prefix       = "${local.pxa_project_name}-${var.PROJECT_CUSTOMER}-${var.PROJECT_ENV}"

  ec2 = {
    security_groups : {
      "bastion" : aws_security_group.sg_bastion.id
      "cicd" : aws_security_group.sg_cicd.id
      "mongo" : aws_security_group.sg_mongo.id
      "ansible" : aws_security_group.ansible.id
    }
  }

  keys = { for item in distinct([for item, _ in var.ec2.instances : element(split("-", item), 0)]) : item => {} }

  ecr = {
    names = [
      "carter-analytics-api",
      "analytics-dashboard",
      "kafka-connector"
    ]
    "imagetag" : "IMMUTABLE"
  }

  eks_oidc_url = var.eks.create ? aws_eks_cluster.eks[0].identity[0].oidc[0].issuer : ""
  eks_oidc_arn = var.eks.create ? aws_iam_openid_connect_provider.eks[0].arn : ""

  databases = {
    mongo = {
      port = 27017
      pxa = {
        name = "carter-analytics"
        usernames = {
          root   = "root"
          admin  = "admin"
          app    = "carter_analytics"
          viewer = "viewer"
        }
      }
    }
  }

  eks_auth_users = var.eks.create ? join("\n", [
    "- groups:",
    "  - system:masters",
    "  userarn: ${var.eks_admin_user_arn}",
    "  username: ${var.eks_admin_user_name}"
  ]) : ""

  kubernetes_config = var.eks.create ? {
    host                   = aws_eks_cluster.eks[0].endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks[0].certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks[0].token
  } : null

}
