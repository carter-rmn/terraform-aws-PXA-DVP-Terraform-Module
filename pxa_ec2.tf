resource "aws_instance" "ec2s" {
  for_each = var.ec2.instances

  ami           = var.ec2.ami
  instance_type = each.value.instance_type
  key_name      = "${local.pxa_prefix}-ec2-${element(split("-", each.key), 0)}"

  vpc_security_group_ids = compact([
    var.vpc.default_security_group.id,
    aws_security_group.sg_allow_ssh.id,
    local.ec2.security_groups[element(split("-", each.key), 0)]
  ])
  subnet_id = element(each.value.public ? (var.vpc.subnets.public) : (var.vpc.subnets.private), each.value.subnet_index)

  associate_public_ip_address = each.value.public

  root_block_device {
    volume_size = each.value.volume_size
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
