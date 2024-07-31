resource "aws_iam_role" "role_role_lb_controller" {
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
  name   = "${local.pxa_prefix}-iam-policy-lb-controller"
  policy = file("./data/AWSLoadBalancerController.json")

  tags = {
    Name        = "${local.pxa_prefix}-iam-policy-lb-controller"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.role_role_lb_controller.name
  policy_arn = aws_iam_policy.policy_lb_controller.arn
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}
