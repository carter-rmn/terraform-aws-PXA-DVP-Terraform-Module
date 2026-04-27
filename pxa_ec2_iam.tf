resource "aws_iam_role" "ec2" {
  count = length(var.ec2.instances) > 0 ? 1 : 0
  name  = "${local.pxa_prefix}-role-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2" {
  count       = length(var.ec2.instances) > 0 ? 1 : 0
  name        = "${local.pxa_prefix}-policy-ec2"
  description = "Policy for CloudWatch agent to send metrics and logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Resource = [
          "arn:aws:logs:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/*",
          "arn:aws:logs:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/*:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeInstanceInformation"
        ],
        Resource = [
          for key, instance in aws_instance.ec2s :
          "arn:aws:ssm:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:managed-instance/${instance.id}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:TerminateSession"
        ],
        Resource = "arn:aws:ssm:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:session/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession"
        ],
        Resource = concat(
          compact([local.ssm_document_arn]),
          [
            for key, instance in aws_instance.ec2s :
            "arn:aws:ec2:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:instance/${instance.id}"
          ]
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  count      = length(var.ec2.instances) > 0 ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = aws_iam_policy.ec2[0].arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count      = length(var.ec2.instances) > 0 ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  count = length(var.ec2.instances) > 0 ? 1 : 0
  name  = "${local.pxa_prefix}-instance-profile-ec2"
  role  = aws_iam_role.ec2[0].name
}
