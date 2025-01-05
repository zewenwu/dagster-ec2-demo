module "database" {
  source = "../terraform-components/aws-rds"

  db_instance_info = {
    instance_name     = "airbnbdb"
    engine            = "postgres"
    engine_version    = "17.2"
    instance_class    = "db.t3.micro"
    allocated_storage = 10
    port              = 5432
    vpc_id            = module.vpc.vpc_id
    subnet_ids        = module.vpc.private_subnets_ids["database"]
  }

  allowed_actions = [
    "rds:DescribeDBInstances",
    "rds:ListTagsForResource",
  ]

  db_username                 = "dbadmin"
  manage_master_user_password = false

  allow_additional_sg_ingress_ids = [
    module.jumphost.launch_template_sg_id
  ]

  tags = local.tags
}

module "jumphost" {
  source = "../terraform-components/aws-ec2"

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

  ec2_subnet_id = module.vpc.private_subnets_ids["application"][0]
  allowed_actions = [
    "ec2:DescribeInstances",
    "ec2:DescribeInstanceStatus",
  ]
  allow_additional_sg_ingress_ids          = []
  allow_additional_sg_ingress_service_port = 22

  tags = local.tags
}
