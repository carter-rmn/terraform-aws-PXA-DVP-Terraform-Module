resource "aws_instance" "ec2s" {
  for_each = var.ec2.instances

  ami           = var.ec2.ami
  instance_type = each.value.instance_type
  key_name      = "${local.pxa_prefix}-ec2-${element(split("-", each.key), 0)}"

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  vpc_security_group_ids = compact([
    var.vpc.default_security_group.id,
    aws_security_group.allow_ssh.id,
    local.ec2.security_groups[element(split("-", each.key), 0)]
  ])
  subnet_id = element(
    each.value.subnet_type == "public" ? var.vpc.subnets.public : var.vpc.subnets.private,
    each.value.subnet_index
  )
  associate_public_ip_address = each.value.public

  depends_on = [aws_key_pair.ec2s]

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = each.value.volume_type

    tags = {
      Name        = "${local.pxa_prefix}-ebs-${each.key}-default"
      Project     = "${local.pxa_project_name}"
      Customer    = var.PROJECT_CUSTOMER
      Environment = var.PROJECT_ENV
      Terraform   = true
    }
  }

  tags = {
    Name        = "${local.pxa_prefix}-ec2-${each.key}"
    Short       = "${each.key}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
