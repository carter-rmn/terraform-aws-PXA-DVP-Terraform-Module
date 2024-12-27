resource "aws_iam_role" "lb_controller" {
  count              = var.eks.create ? 1 : 0
  name               = "${local.pxa_prefix}-iam-role-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  lifecycle {
    ignore_changes = [assume_role_policy]
  }

  tags = {
    Name        = "${local.pxa_prefix}-iam-role-lb-controller"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_policy" "policy_lb_controller" {
  count  = var.eks.create ? 1 : 0
  name   = "${local.pxa_prefix}-iam-policy-lb-controller"
  policy = file("${path.module}/data/AWSLoadBalancerController.json")

  tags = {
    Name        = "${local.pxa_prefix}-iam-policy-lb-controller"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = var.eks.create ? 1 : 0
  role       = aws_iam_role.lb_controller[count.index].name
  policy_arn = aws_iam_policy.policy_lb_controller[count.index].arn
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.eks.create ? replace(local.eks.oidc.url, "https://", "") : ""}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.eks.create ? replace(local.eks.oidc.url, "https://", "") : ""}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [local.eks_oidc.arn]
      type        = "Federated"
    }
  }
}
