# EKS Network Configuration - NonProd
# Creates EKS subnets using existing VPC and NAT Gateway

project_name = "eks"
environment  = "nonprod"
aws_region   = "us-east-1"

# Existing Infrastructure (Update these with your actual IDs)
vpc_id         = "vpc-0457de39c6afcb5c5"  # Replace with your VPC ID
vpc_cidr_block = "192.168.0.0/16"         # Replace with your VPC CIDR block
nat_gateway_id = "nat-066241edc40bc430c"  # Replace with your NAT Gateway ID

# Availability Zones
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS Subnet Configuration (Update CIDRs to match your VPC CIDR range)
eks_subnet_cidrs = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]

# Additional Tags
tags = {
  Project    = "AWS Blueprint"
  CostCenter = "Engineering"
  Purpose    = "EKS"
}
