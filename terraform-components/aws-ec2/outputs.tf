
### EC2 Instance
output "ec2_name" {
  description = "The name of the EC2 instance"
  value       = aws_launch_template.template.name
}

output "ec2_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.instance.id
}

output "ec2_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.instance.arn
}

### EC2 Consumer policy
output "ec2_consumer_policy_arn" {
  value       = length(var.allowed_actions) > 0 ? aws_iam_policy.consumer[0].arn : null
  description = "The ARN of the IAM policy for the consumer."
}

### Launch Template
output "launch_template_name" {
  description = "The name of the launch template"
  value       = aws_launch_template.template.name
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.template.id
}

output "launch_template_sg_id" {
  description = "The ID of the security group of the launch template"
  value       = module.ec2_launch_template_sg.security_group_id
}

output "launch_template_iam_role_name" {
  description = "The name of the IAM role of the launch template"
  value       = aws_iam_role.launch_template.name
}

output "launch_template_iam_role_id" {
  description = "The ID of the IAM role of the launch template"
  value       = aws_iam_role.launch_template.id
}

output "launch_template_iam_instance_profile_name" {
  description = "The name of the IAM instance profile of the launch template"
  value       = aws_iam_instance_profile.launch_template.name
}

output "launch_template_iam_instance_profile_id" {
  description = "The ID of the IAM instance profile of the launch template"
  value       = aws_iam_instance_profile.launch_template.id
}

### Secret
output "secret_name" {
  description = "The name of the secret"
  value       = length(var.launch_template_secrets) > 0 ? aws_secretsmanager_secret.launch_template_secret[0].name : null
}

output "secret_arn" {
  description = "The ARN of the secret"
  value       = length(var.launch_template_secrets) > 0 ? aws_secretsmanager_secret.launch_template_secret[0].arn : null
}
