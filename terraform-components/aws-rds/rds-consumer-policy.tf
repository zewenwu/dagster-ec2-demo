resource "aws_iam_policy" "consumer" {
  count = length(var.allowed_actions) > 0 ? 1 : 0
  name  = local.instance_consumer_policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowActionsOnRDSInstance"
        Effect   = "Allow"
        Action   = var.allowed_actions
        Resource = aws_db_instance.database.arn
      },
      {
        Sid    = "AllowGettingMasterUserPassword"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.manage_master_user_password ? aws_db_instance.database.master_user_secret[0].secret_arn : aws_secretsmanager_secret.master_user_credentials_secret[0].arn
      }
    ]
  })
}
