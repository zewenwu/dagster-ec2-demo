resource "aws_iam_policy" "consumer" {
  count = length(var.allowed_actions) > 0 ? 1 : 0
  name  = local.ec2_consumer_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowActionsOnEC2Instance"
        Effect   = "Allow"
        Action   = var.allowed_actions
        Resource = aws_instance.instance.arn
      }
    ]
  })
}
