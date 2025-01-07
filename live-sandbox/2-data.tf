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
    name          = "jumphost"
    image_id      = "latest"
    instance_type = "t2.micro"
    vpc_id        = module.vpc.vpc_id
    instance_role_policy_arns = {
      rds_consumer = module.database.consumer_policy_arn
    }
    block_volume_size = 10
    user_data_path    = ""
    user_data_base64 = base64encode(
      templatefile("${path.module}/scripts/ec2_ingest_script.tftpl", {
        data_folder                = "./"
        db_host                    = module.database.rds_address
        db_port                    = module.database.rds_port
        db_name                    = module.database.rds_name
        db_credentials_secret_name = module.database.master_user_credentials_secret_name
        aws_region                 = "us-east-1"
      })
    )
  }
  launch_template_secrets = {}

  ec2_subnet_id                            = module.vpc.private_subnets_ids["application"][0]
  allowed_actions                          = []
  allow_additional_sg_ingress_ids          = []
  allow_additional_sg_ingress_service_port = 22

  tags = local.tags
}
