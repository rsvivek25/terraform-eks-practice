# EKS Cluster Configuration - NonProd Test

project_name = "aws-blueprint"
environment  = "nonprod"
aws_region   = "us-east-1"

# Cluster Configuration
cluster_name    = "aws-blueprint-nonprod-test"
cluster_version = "1.31"

# Network Configuration
# Update these with your actual VPC and subnet IDs
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx", # private-subnet-us-east-1a
  "subnet-yyyyyyyyyyyyyyyyy", # private-subnet-us-east-1b
  "subnet-zzzzzzzzzzzzzzzzz", # private-subnet-us-east-1c
]

# Security Features
enable_secrets_encryption          = true
enable_cluster_deletion_protection = true
enable_cluster_control_plane_logging = true
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# Cluster Access
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true
cluster_endpoint_public_access_cidrs = [
  # "10.0.0.0/8",      # Internal networks
  # "203.0.113.0/24",  # Office IP range
  "0.0.0.0/0"          # Allow all (update for production)
]

# High Availability
enable_zonal_shift = true

# Additional Tags
tags = {
  Project     = "AWS Blueprint"
  CostCenter  = "Engineering"
  Owner       = "QA Team"
  Cluster     = "test"
  Purpose     = "Quality assurance and integration testing"
}
