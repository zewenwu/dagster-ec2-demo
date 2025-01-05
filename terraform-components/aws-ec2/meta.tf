# Latest Amazon Linux 2 AMI
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Append random string to SM Secret names because once we tear down the infra, the secret does not actually
# get deleted right away, which means that if we then try to recreate the infra, it'll fail as the
# secret name already exists.
resource "random_string" "random_suffix" {
  length  = 5
  special = false
}

locals {
  ec2_consumer_policy_name = "${var.launch_template_info.name}-ec2-consumer-policy"

  # Launch template
  ec2_launch_template_iam_role_name             = "${var.launch_template_info.name}-role"
  ec2_launch_template_iam_instance_profile_name = "${var.launch_template_info.name}-profile"
  ec2_launch_template_secret_name               = "${var.launch_template_info.name}-secret-${random_string.random_suffix.result}"
}
