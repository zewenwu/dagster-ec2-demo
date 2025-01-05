### VPC
output "public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}

output "private_subnets_ids" {
  value = module.vpc.private_subnets_ids
}

### Database
output "database_password_secret_arn" {
  value = module.database.master_password_secret_arn
}
