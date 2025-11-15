################################################################################
# EKS Dev Cluster Configuration - NonProd
################################################################################

################################################################################
# General Configuration
################################################################################

environment = "nonprod"
aws_region  = "us-east-1"

################################################################################
# Basic Cluster Configuration
################################################################################

cluster_name                  = "eks-nonprod-dev"
cluster_version               = "1.33"
cluster_upgrade_support_type  = "STANDARD"

################################################################################
# Network Configuration
################################################################################

vpc_id = "vpc-0457de39c6afcb5c5"

# Private Subnet IDs from eks-network output
private_subnet_ids = [
  "subnet-0e73a7d816dea7856", # us-east-1a
  "subnet-02bc0bc929536596c", # us-east-1b
  "subnet-02654a38207b7112d"  # us-east-1c
]

################################################################################
# Cluster Endpoint Access Configuration
################################################################################

cluster_endpoint_public_access       = false
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

################################################################################
# Auto Mode Configuration
################################################################################

enable_default_node_pools = "system"

################################################################################
# Encryption Configuration
################################################################################

enable_secrets_encryption = true
kms_key_arn               = "" # Leave empty to create new KMS key
kms_key_deletion_window   = 30
kms_enable_key_rotation   = true

################################################################################
# Logging Configuration
################################################################################

enable_cluster_control_plane_logging   = true
cluster_enabled_log_types              = ["api", "audit"]
cloudwatch_log_group_retention_in_days = 7
cloudwatch_log_group_kms_key_id        = ""
cloudwatch_log_group_class             = "STANDARD"

################################################################################
# Access & Security Configuration
################################################################################

enable_cluster_creator_admin_permissions = true
additional_security_group_ids            = ["sg-0c6c8ce125b0c1296"]
enable_cluster_deletion_protection       = true

################################################################################
# Zonal Shift Configuration
################################################################################

enable_zonal_shift = true

################################################################################
# Cluster Add-ons
################################################################################

# Add-ons are configured in main.tf with their IAM roles
# You can add additional add-ons here if needed
cluster_addons = {}

################################################################################
# EKS Add-on Configuration (EFS CSI Driver, External DNS)
################################################################################

# EFS CSI Driver
enable_efs_csi_driver = true
efs_csi_driver_version = "" # Leave empty for latest version, or specify like "v2.1.1-eksbuild.1"

# External DNS
enable_external_dns = true
external_dns_version = "" # Leave empty for latest version, or specify like "v1.15.0-eksbuild.1"

# Route53 zones that External DNS can manage
# Use specific zone ARNs for production: ["arn:aws:route53:::hostedzone/Z1234567890ABC"]
external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/*"]

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
