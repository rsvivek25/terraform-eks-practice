output "vpc_id" {
  description = "VPC ID"
  value       = module.eks_network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.eks_network.vpc_cidr
}

output "eks_subnet_ids" {
  description = "EKS subnet IDs"
  value       = module.eks_network.eks_subnet_ids
}

output "eks_subnet_cidrs" {
  description = "EKS subnet CIDR blocks"
  value       = module.eks_network.eks_subnet_cidrs
}

output "eks_subnet_availability_zones" {
  description = "EKS subnet availability zones"
  value       = module.eks_network.eks_subnet_availability_zones
}

output "eks_route_table_id" {
  description = "EKS route table ID"
  value       = module.eks_network.eks_route_table_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.eks_network.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.eks_network.nat_gateway_public_ip
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = module.eks_network.eks_cluster_security_group_id
}

output "eks_cluster_security_group_name" {
  description = "Security group name for EKS cluster"
  value       = module.eks_network.eks_cluster_security_group_name
}
