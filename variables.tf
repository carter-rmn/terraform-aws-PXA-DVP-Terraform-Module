# AWS
variable "AWS_REGION" {}

# PROJECT
variable "PROJECT_CUSTOMER" {}
variable "PROJECT_ENV" {}
variable "PROJECT_PRENAME" {}

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
    create = bool
    new = object({
      number_of_broker_nodes = number
      instance_type          = string
      volume_size            = number
    })
    existing = object({
      bootstrap_brokers = string
    })
  })
}

variable "eks" {
  type = object({
    create = bool
    new = object({
      node_groups = list(object({
        desired_size  = number
        max_size      = number
        min_size      = number
        instance_type = string
      }))
    })
    existing = object({
      lb_contorller_arn = string
      openid_connect = object({
        issuer = string
        arn    = string
      })
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
