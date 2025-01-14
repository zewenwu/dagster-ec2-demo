### EC2 Instance
#trivy:ignore:avd-aws-0131
resource "aws_instance" "instance" {

  # Launch Template
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  # User data (Bug: Passing down from Launch Template cause continuous changes in user data in Terraform)
  user_data                   = var.launch_template_info.user_data_path != null ? filebase64(var.launch_template_info.user_data_path) : null
  user_data_base64            = var.launch_template_info.user_data_base64
  user_data_replace_on_change = false

  # Subnet
  subnet_id = var.ec2_subnet_id

  # Metadata
  tags = merge(
    {
      Name = aws_launch_template.template.name
    },
    var.tags
  )
}
