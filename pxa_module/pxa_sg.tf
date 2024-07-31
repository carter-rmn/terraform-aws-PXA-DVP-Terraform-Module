# MSK
resource "aws_security_group" "sg_allow_msk" {
  name        = "${local.pxa_prefix}-sg-allow-msk"
  description = "Allow MSK traffic"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = concat(local.vpc.cidr_blocks.private, local.vpc.cidr_blocks.database, local.vpc.cidr_blocks.public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-allow-msk"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

# EC2
resource "aws_security_group" "sg_allow_ssh" {
  name        = "${local.pxa_prefix}-sg-allow-ssh"
  description = "Allow SSH traffic"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 22 // todo needs to be configurable
    to_port     = 22 // todo needs to be configurable
    protocol    = "tcp"
    cidr_blocks = concat(local.vpc.cidr_blocks.private, local.vpc.cidr_blocks.database, local.vpc.cidr_blocks.public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-allow-ssh"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_security_group" "sg_bastion" {
  name        = "${local.pxa_prefix}-sg-bastion"
  description = "Allow Bastion Connection"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-bastion"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_security_group" "sg_lambda" {
  name        = "${local.pxa_prefix}-sg-lambda"
  description = "Allow Lambda Function Access"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-lambda"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_security_group" "sg_cicd" {
  name        = "${local.pxa_prefix}-sg-cicd"
  description = "Allow CICD Connection"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = concat(local.vpc.cidr_blocks.private, local.vpc.cidr_blocks.database, local.vpc.cidr_blocks.public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-cicd"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_security_group" "sg_mongo" {
  name        = "${local.pxa_prefix}-sg-mongo"
  description = "Allow Mongo Connection"

  vpc_id = local.vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = concat(local.vpc.cidr_blocks.private, local.vpc.cidr_blocks.database, local.vpc.cidr_blocks.public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-mongo"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}







