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

  db_username                     = "dbadmin"
  allow_additional_sg_ingress_ids = []

  tags = local.tags
}
