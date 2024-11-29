# AWS
variable "AWS_REGION" {}

# PROJECT
variable "PROJECT_CUSTOMER" {}
variable "PROJECT_ENV" {}
variable "PROJECT_PRENAME" {}

variable "eks_admin_user_name" {}
variable "eks_admin_user_arn" {}

variable "vpc" {
  type = object({
    id = string

    default_security_group = object({
      id = string
    })

    subnets = object({
      public   = list(string)
      private  = list(string)
      database = list(string)
    })

    cidr_blocks = object({
      public   = list(string)
      private  = list(string)
      database = list(string)
    })
  })
}

variable "msk" {
  type = object({
    create                 = bool
    id                     = string
    number_of_broker_nodes = number
    instance_type          = string
    volume_size            = number
  })
}

variable "eks" {
  type = object({
    create = bool

    eks_node_group = object({
      desired_size  = number
      max_size      = number
      min_size      = number
      instance_type = string
    })
  })
}

variable "ec2" {
  type = object({
    ami = string
    instances = map(object({
      instance_type = string
      subnet_index  = number
      volume_size   = number
      public        = bool
    }))
  })
}

variable "api_gateway" {
  type = object({
    authenticate_uri = string
    geolocation_uri  = string
  })
}
