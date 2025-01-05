resource "aws_iam_policy" "consumer" {
  name   = local.ec2_consumer_policy_name
  policy = data.aws_iam_policy_document.consumer.json
}

data "aws_iam_policy_document" "consumer" {

  dynamic "statement" {
    for_each = length(var.allowed_actions) > 0 ? [1] : []
    content {
      sid     = "AllowActionsOnEC2Instance"
      effect  = "Allow"
      actions = var.allowed_actions
      resources = [
        aws_instance.instance.arn,
      ]
    }
  }
}
