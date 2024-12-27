# MSK
resource "aws_security_group" "allow_msk" {
  count       = var.msk.create ? 1 : 0
  name        = "${local.pxa_prefix}-sg-allow-msk"
  description = "Allow MSK traffic"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc.cidr_blocks.private, var.vpc.cidr_blocks.database, var.vpc.cidr_blocks.public)
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
resource "aws_security_group" "allow_ssh" {
  name        = "${local.pxa_prefix}-sg-allow-ssh"
  description = "Allow SSH traffic"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 22 // todo needs to be configurable
    to_port     = 22 // todo needs to be configurable
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc.cidr_blocks.private, var.vpc.cidr_blocks.database, var.vpc.cidr_blocks.public)
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

resource "aws_security_group" "ansible" {
  name        = "${local.pxa_prefix}-sg-ansible"
  description = "Allow Ansible Operation"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc.cidr_blocks.private, var.vpc.cidr_blocks.database, var.vpc.cidr_blocks.public)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.pxa_prefix}-sg-ansible"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_security_group" "bastion" {
  name        = "${local.pxa_prefix}-sg-bastion"
  description = "Allow Bastion Connection"

  vpc_id = var.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "35.182.251.28/32",
      "103.189.99.5/32"
    ]
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

resource "aws_security_group" "cicd" {
  name        = "${local.pxa_prefix}-sg-cicd"
  description = "Allow CICD Connection"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc.cidr_blocks.private, var.vpc.cidr_blocks.database, var.vpc.cidr_blocks.public)
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

resource "aws_security_group" "lambda" {
  name        = "${local.pxa_prefix}-sg-lambda"
  description = "Allow Lambda Function Access"

  vpc_id = var.vpc.id

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

resource "aws_security_group" "mongo" {
  name        = "${local.pxa_prefix}-sg-mongo"
  description = "Allow Mongo Connection"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = concat(var.vpc.cidr_blocks.private, var.vpc.cidr_blocks.database, var.vpc.cidr_blocks.public)
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

resource "aws_security_group" "openvpn" {
  name        = "${local.pxa_prefix}-sg-openvpn"
  description = "Allow Openvpn Connection"

  vpc_id = var.vpc.id

  ingress {
    from_port   = 1194
    to_port     = 1194
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
    Name        = "${local.pxa_prefix}-sg-openvpn"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
