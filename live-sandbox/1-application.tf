module "jump_host" {
  source = "../terraform-components/aws-ec2"

  launch_template_info = {
    name          = "jump-host"
    image_id      = "latest"
    instance_type = "t2.micro"
    vpc_id        = module.vpc.vpc_id
    instance_role_policy_arns = {
      rds_consumer = module.database.consumer_policy_arn
    }
    block_volume_size = 10
    user_data_path    = null
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

module "dagster_host" {
  source = "../terraform-components/aws-ec2"

  launch_template_info = {
    name          = "dagster-host"
    image_id      = "latest"
    instance_type = "t2.micro"
    vpc_id        = module.vpc.vpc_id
    instance_role_policy_arns = {
      rds_consumer = module.database.consumer_policy_arn
    }
    block_volume_size = 10
    user_data_path    = "scripts/ec2_host_dagster.sh"
    user_data_base64  = null
  }
  launch_template_secrets = {}

  ec2_subnet_id                            = module.vpc.private_subnets_ids["application"][0]
  allowed_actions                          = []
  allow_additional_sg_ingress_ids          = [module.jump_host.launch_template_sg_id]
  allow_additional_sg_ingress_service_port = 3000

  tags = local.tags
}
