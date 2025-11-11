################################################################################
# EKS Dev Cluster Configuration - NonProd
################################################################################

################################################################################
# General Configuration
################################################################################

project_name = "aws-blueprint"
environment  = "nonprod"
aws_region   = "us-east-1"

################################################################################
# Basic Cluster Configuration
################################################################################

cluster_name    = "aws-blueprint-nonprod-dev"
cluster_version = "1.31"

# Subnet IDs from eks-network output
# Update these with actual subnet IDs from: terraform output -state=../../eks-network/terraform.tfstate eks_subnet_ids
subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx", # us-east-1a
  "subnet-xxxxxxxxxxxxxxxxx", # us-east-1b
  "subnet-xxxxxxxxxxxxxxxxx"  # us-east-1c
]

################################################################################
# Network Configuration
################################################################################

endpoint_private_access = true

# Security Group ID from eks-network output
# Update this with actual security group ID from: terraform output -state=../../eks-network/terraform.tfstate eks_cluster_security_group_id
cluster_additional_security_group_ids = [
  "sg-xxxxxxxxxxxxxxxxx" # EKS cluster security group from eks-network
]

################################################################################
# Auto Mode Configuration
################################################################################

auto_mode_node_pools = ["general-purpose"]

################################################################################
# Encryption Configuration
################################################################################

kms_key_arn                 = "" # Leave empty to create new KMS key
kms_deletion_window_in_days = 30

################################################################################
# Logging Configuration
################################################################################

enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

################################################################################
# Access & Security Configuration
################################################################################

authentication_mode                         = "API_AND_CONFIG_MAP"
bootstrap_cluster_creator_admin_permissions = true
enable_cluster_deletion_protection          = false

################################################################################
# Add-ons & Advanced Configuration
################################################################################

bootstrap_self_managed_addons = false
support_type                  = "STANDARD"
zonal_shift_enabled           = true

################################################################################
# Tags
################################################################################

tags = {
  Project     = "AWS Blueprint"
  CostCenter  = "Engineering"
  Environment = "nonprod"
  Cluster     = "dev"
  ManagedBy   = "Terraform"
}
