### EC2 Launch Template
variable "launch_template_info" {
  description = <<EOH
The info block for the launch template to deploy.
For instance_role_policy_arns to attach to the Launch Template EC2 Instance Role, use for example: { rds_arn = module.postgres_db.rds_policy_arn }
EOH
  type = object({
    name                      = string
    image_id                  = string
    instance_type             = string
    vpc_id                    = string
    instance_role_policy_arns = map(string)
    block_volume_size         = number
    user_data_path            = string
    user_data_base64          = string
  })
  default = {
    name          = "webapp"
    image_id      = "latest"
    instance_type = "t2.micro"
    vpc_id        = "vpc-123"
    instance_role_policy_arns = {
      rds_consumer = "arn:aws:iam::123456789012:policy/MyRDSConsumerPolicy"
      s3_consumer  = "arn:aws:iam::123456789012:policy/MyS3ConsumerPolicy"
    }
    block_volume_size = 10
    user_data_path    = "user-data/http-example-simple.sh"
    user_data_base64  = null
  }
}

variable "launch_template_secrets" {
  description = "Map of secret name (as reflected in Secrets Manager) and secret JSON string associated that can be accessed by the EC2 instances of the launch template."
  type        = map(string)
  default     = {}
}

### EC2 instance
variable "ec2_subnet_id" {
  description = "The subnet ID in which the EC2 instance will be deployed"
  type        = string
}

variable "allowed_actions" {
  description = "List of EC2 actions which are allowed for same account principals for the consumer policy"
  type        = list(string)
  default = [
    "ec2:DescribeAccountAttributes",
    "ec2:DescribeAvailabilityZones",
    "ec2:DescribeInternetGateways",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeSubnets",
    "ec2:DescribeVpcAttribute",
    "ec2:DescribeVpcs"
  ]
}

### EC2 Security Group
variable "allow_additional_sg_ingress_ids" {
  description = "List of additional security group IDs to allow ingress traffic into the RDS instance"
  type        = list(string)
  default     = []
}

variable "allow_additional_sg_ingress_service_port" {
  description = "The port to allow in the additional security group"
  type        = number
  default     = 22
}

### Metadata
variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}
