### VPC
output "public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}

output "private_subnets_ids" {
  value = module.vpc.private_subnets_ids
}

### Database
output "database_host_name" {
  value = module.database.rds_address
}

output "database_port" {
  value = module.database.rds_port
}

output "database_name" {
  value = module.database.rds_name
}

output "database_credentials_secret_name" {
  value = module.database.master_user_credentials_secret_name
}

output "jumphost_instance_id" {
  value = module.jumphost.ec2_id
}
