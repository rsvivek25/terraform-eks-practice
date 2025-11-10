output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.network.database_subnet_ids
}

output "database_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.network.database_subnet_group_name
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.network.nat_gateway_public_ips
}
