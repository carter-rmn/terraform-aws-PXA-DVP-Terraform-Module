resource "aws_iam_user_policy" "pxa" {
  for_each = { for item in local.s3_users : "${item.user}-${item.name}" => item }
  name     = "${local.pxa_prefix}-policy-s3-app-${each.value.name}"
  user     = aws_iam_user.users[each.value.user].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${aws_s3_bucket.s3s[each.value.name].arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${"${aws_s3_bucket.s3s[each.value.name].arn}"}/*",
          "${"${aws_s3_bucket.s3s[each.value.name].arn}"}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Modify",
          "cassandra:Create",
          "cassandra:Alter",
          "cassandra:Drop"
        ]
        Resource = compact([
          "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/system*",
          (
            aws_keyspaces_keyspace.carter_analytics != null && length(aws_keyspaces_keyspace.carter_analytics) > 0
          ) ?
            "arn:aws:cassandra:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:/keyspace/${aws_keyspaces_keyspace.carter_analytics[0].name}/table/*"
          : null
        ])
      },
      {
        Sid    = "ListVPCEndpoints"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcEndpoints"
        ]
        Resource = "*"
      }
    ]
  })
}
