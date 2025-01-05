### EC2 Instance
#trivy:ignore:avd-aws-0131
resource "aws_instance" "instance" {

  # Launch Template
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  # Subnet
  subnet_id = var.ec2_subnet_id

  # Metadata
  # Tags should be provided by the launch template
}
