resource "aws_iam_role" "chatbot" {
  count = var.msk.create && var.msk_alerting.enabled ? 1 : 0

  name = "${local.pxa_prefix}-chatbot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "chatbot.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "chatbot_readonly" {
  count = var.msk.create && var.msk_alerting.enabled ? 1 : 0

  role       = aws_iam_role.chatbot[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
