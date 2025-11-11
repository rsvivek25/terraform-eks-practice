################################################################################
# EKS Dev Cluster Configuration - NonProd
################################################################################

################################################################################
# General Configuration
################################################################################

project_name = "dev"
environment  = "nonprod"
aws_region   = "us-east-1"

################################################################################
# Basic Cluster Configuration
################################################################################

cluster_name    = "eks-nonprod-dev"
cluster_version = "1.33"

################################################################################
# Network Configuration
################################################################################

vpc_id = "vpc-0fcb9a31b99607e0b"

# Subnet IDs from eks-network output
# Update these with actual subnet IDs from: terraform output -state=../../eks-network/terraform.tfstate eks_subnet_ids
subnet_ids = [
  "subnet-0e73a7d816dea7856", # us-east-1a
  "subnet-02bc0bc929536596c", # us-east-1b
  "subnet-02654a38207b7112d"  # us-east-1c
]

endpoint_private_access = true

# Security Group ID from eks-network output
# Update this with actual security group ID from: terraform output -state=../../eks-network/terraform.tfstate eks_cluster_security_group_id
cluster_additional_security_group_ids = [
  "sg-098cb306b2a615258" # EKS cluster security group from eks-network
]

################################################################################
# Auto Mode Configuration
################################################################################

auto_mode_node_pools = ["system"]

################################################################################
# Encryption Configuration
################################################################################

kms_key_arn                 = "" # Leave empty to create new KMS key
kms_deletion_window_in_days = 30

################################################################################
# Logging Configuration
################################################################################

enabled_cluster_log_types = ["api", "audit"]

################################################################################
# Access & Security Configuration
################################################################################

authentication_mode                         = "API_AND_CONFIG_MAP"
bootstrap_cluster_creator_admin_permissions = true
enable_cluster_deletion_protection          = true

################################################################################
# Upgrade & Advanced Configuration
################################################################################

support_type        = "STANDARD"
zonal_shift_enabled = true

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
