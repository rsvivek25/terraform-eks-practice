# Network Configuration - NonProd

project_name = "aws-blueprint"
environment  = "nonprod"
aws_region   = "us-east-1"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Subnet Configuration
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

# Network Features
enable_dns_hostnames    = true
enable_dns_support      = true
create_internet_gateway = true
enable_nat_gateway      = true
single_nat_gateway      = true  # Set to false for HA across AZs (higher cost)

# VPC Flow Logs
enable_flow_logs         = true
flow_logs_traffic_type   = "ALL"
flow_logs_retention_days = 30

# Additional Tags
tags = {
  Project     = "AWS Blueprint"
  CostCenter  = "Engineering"
  Compliance  = "Standard"
}
