# AWS
variable "AWS_REGION" {}

# PROJECT
variable "PROJECT_CUSTOMER" {}
variable "PROJECT_ENV" {}

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
    id     = string
  })
}

variable "eks" {
  type = object({
    create = bool
  })
}
