output "vpc_id" {
  description = "ID of the VPC"
  value       = data.aws_vpc.existing.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = data.aws_vpc.existing.cidr_block
}

output "eks_subnet_ids" {
  description = "IDs of the EKS private subnets"
  value       = aws_subnet.eks_private[*].id
}

output "eks_subnet_cidrs" {
  description = "CIDR blocks of the EKS private subnets"
  value       = aws_subnet.eks_private[*].cidr_block
}

output "eks_subnet_availability_zones" {
  description = "Availability zones of the EKS subnets"
  value       = aws_subnet.eks_private[*].availability_zone
}

output "eks_route_table_id" {
  description = "ID of the EKS private route table"
  value       = aws_route_table.eks_private.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = data.aws_nat_gateway.existing.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = data.aws_nat_gateway.existing.public_ip
}
