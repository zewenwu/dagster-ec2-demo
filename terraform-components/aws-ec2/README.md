# AWS EC2 Instance Component

Amazon EC2 provides a wide selection of instance types optimized to fit different use cases. Instance types comprise varying combinations of CPU, memory, storage, and networking capacity and give you the flexibility to choose the appropriate mix of resources for your applications. Each instance type includes one or more instance sizes, allowing you to scale your resources to the requirements of your target workload.

This module creates:

- **EC2 Instance**: An EC2 instance.
- **Launch Template**: To define the instance configuration and launch settings for the EC2 instance
- **Launch Template Security Group**: To control inbound and outbound traffic to the EC2 instance
- **Launch Template IAM Instance Role**: Role that every EC2 instance assumes.
- **Launch Template Secret**: Optional, a secret that the IAM instance role can use to access sensitive information in EC2.
- **Consumer Policy**: A policy that can be added to an IAM role which allows the role to access the RDS database.
- **Managed Master Password Secret**: Optional, An AWS Secrets Manager secret containing the master password for the RDS database.

## Architecture

![alt text](./images/ec2.svg)

## Implementation decisions

### Launch Template Instance Profile and Role

The module creates an IAM instance profile and role with any user-specified policy arn attached and associates it to the launch template of the EC2.

Additionally, the IAM role is associated with the `AmazonSSMManagedInstanceCore` policy to allow the instances to communicate with the Session Manager service. This enables Session Manager Connect to allow users to connect to EC2 instance using the EC2 console. This is useful for scenarios where you want to provide users with a browser-based SSH experience without exposing the instances to the internet.

Additionally, ensure that the instances have outbound internet access to connect to the Session Manager service. This can be achieved by deploying the instances in private subnets with a NAT Gateway reference in its route table.

For more information on Session Manager Connect, refer to the [AWS documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-add-permissions-to-existing-profile.html).

### Launch Template Secret

This module allows users to specify a list of secrets that can be stored as a secret in the AWS Secrets Manager. This secret is accessible via the IAM role of the Launch Template.

This is useful for scenarios where you want to store sensitive information such as database passwords, API keys, and so on.

### Launch Template User Data

The module allows users to specify a user data script to be executed when the instances are launched. The user data script can be used to install software packages, configure the instance, and so on.

### Launch Template Security Groups

The module creates a security group for the Launch Template.

The Launch Template security group is created with the following rules:

- Inbound: Allow traffic from the Launch Template security group (itself) on all protocols and ports.
- Inbound: Allow additional user-specified security group IDs on user-specified port.
- Outbound: Allow all protocols and ports outbound.

### EC2 Consumer Policy

The consumer policy is a policy that can be added to an external IAM role which allows the role to permissions to the EC2 instance. The policy is created with the following permissions:

- Allow any user-specified EC2 actions on the created EC2 instance.

## How to use this module

```terraform
module "jumphost" {
  source = "path/to/this/module"

  launch_template_info = {
    name                      = "jumphost"
    image_id                  = "latest"
    instance_type             = "t2.micro"
    vpc_id                    = module.vpc.vpc_id
    instance_role_policy_arns = {}
    block_volume_size         = 10
    user_data_path            = "user-data/http-example-simple.sh"
  }
  launch_template_secrets = {}

  ec2_subnet_id                            = module.vpc.private_subnets_ids["application"][0]
  allowed_actions                          = []
  allow_additional_sg_ingress_ids          = []
  allow_additional_sg_ingress_service_port = 22

  tags = local.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.82.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_launch_template_sg"></a> [ec2\_launch\_template\_sg](#module\_ec2\_launch\_template\_sg) | ../aws-sg | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.launch_template_get_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.launch_template_get_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.launch_template_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.launch_template_role_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_launch_template.template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_secretsmanager_secret.launch_template_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.ec2_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_string.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.launch_template_get_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_additional_sg_ingress_ids"></a> [allow\_additional\_sg\_ingress\_ids](#input\_allow\_additional\_sg\_ingress\_ids) | List of additional security group IDs to allow ingress traffic into the RDS instance | `list(string)` | `[]` | no |
| <a name="input_allow_additional_sg_ingress_service_port"></a> [allow\_additional\_sg\_ingress\_service\_port](#input\_allow\_additional\_sg\_ingress\_service\_port) | The port to allow in the additional security group | `number` | `22` | no |
| <a name="input_allowed_actions"></a> [allowed\_actions](#input\_allowed\_actions) | List of EC2 actions which are allowed for same account principals for the consumer policy | `list(string)` | <pre>[<br/>  "ec2:DescribeAccountAttributes",<br/>  "ec2:DescribeAvailabilityZones",<br/>  "ec2:DescribeInternetGateways",<br/>  "ec2:DescribeSecurityGroups",<br/>  "ec2:DescribeSubnets",<br/>  "ec2:DescribeVpcAttribute",<br/>  "ec2:DescribeVpcs"<br/>]</pre> | no |
| <a name="input_ec2_subnet_id"></a> [ec2\_subnet\_id](#input\_ec2\_subnet\_id) | The subnet ID in which the EC2 instance will be deployed | `string` | n/a | yes |
| <a name="input_launch_template_info"></a> [launch\_template\_info](#input\_launch\_template\_info) | The info block for the launch template to deploy.<br/>For instance\_role\_policy\_arns to attach to the Launch Template EC2 Instance Role, use for example: { rds\_arn = module.postgres\_db.rds\_policy\_arn } | <pre>object({<br/>    name                      = string<br/>    image_id                  = string<br/>    instance_type             = string<br/>    vpc_id                    = string<br/>    instance_role_policy_arns = map(string)<br/>    block_volume_size         = number<br/>    user_data_path            = string<br/>    user_data_base64          = string<br/>  })</pre> | <pre>{<br/>  "block_volume_size": 10,<br/>  "image_id": "latest",<br/>  "instance_role_policy_arns": {<br/>    "rds_consumer": "arn:aws:iam::123456789012:policy/MyRDSConsumerPolicy",<br/>    "s3_consumer": "arn:aws:iam::123456789012:policy/MyS3ConsumerPolicy"<br/>  },<br/>  "instance_type": "t2.micro",<br/>  "name": "webapp",<br/>  "user_data_base64": null,<br/>  "user_data_path": "user-data/http-example-simple.sh",<br/>  "vpc_id": "vpc-123"<br/>}</pre> | no |
| <a name="input_launch_template_secrets"></a> [launch\_template\_secrets](#input\_launch\_template\_secrets) | Map of secret name (as reflected in Secrets Manager) and secret JSON string associated that can be accessed by the EC2 instances of the launch template. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_arn"></a> [ec2\_arn](#output\_ec2\_arn) | The ARN of the EC2 instance |
| <a name="output_ec2_consumer_policy_arn"></a> [ec2\_consumer\_policy\_arn](#output\_ec2\_consumer\_policy\_arn) | The ARN of the IAM policy for the consumer. |
| <a name="output_ec2_id"></a> [ec2\_id](#output\_ec2\_id) | The ID of the EC2 instance |
| <a name="output_ec2_name"></a> [ec2\_name](#output\_ec2\_name) | The name of the EC2 instance |
| <a name="output_launch_template_iam_instance_profile_id"></a> [launch\_template\_iam\_instance\_profile\_id](#output\_launch\_template\_iam\_instance\_profile\_id) | The ID of the IAM instance profile of the launch template |
| <a name="output_launch_template_iam_instance_profile_name"></a> [launch\_template\_iam\_instance\_profile\_name](#output\_launch\_template\_iam\_instance\_profile\_name) | The name of the IAM instance profile of the launch template |
| <a name="output_launch_template_iam_role_id"></a> [launch\_template\_iam\_role\_id](#output\_launch\_template\_iam\_role\_id) | The ID of the IAM role of the launch template |
| <a name="output_launch_template_iam_role_name"></a> [launch\_template\_iam\_role\_name](#output\_launch\_template\_iam\_role\_name) | The name of the IAM role of the launch template |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the launch template |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | The name of the launch template |
| <a name="output_launch_template_sg_id"></a> [launch\_template\_sg\_id](#output\_launch\_template\_sg\_id) | The ID of the security group of the launch template |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | The ARN of the secret |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | The name of the secret |
<!-- END_TF_DOCS -->
