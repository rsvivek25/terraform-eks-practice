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
additional_security_group_ids            = ["sg-076f27446242b0732"]
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
# ArgoCD Configuration
################################################################################

argocd_namespace            = "argocd"
argocd_chart_version        = "8.0.0"
argocd_ha_enabled           = true
argocd_replicas             = 2
argocd_redis_ha_enabled     = true
argocd_server_service_type  = "ClusterIP"
argocd_server_insecure      = true
argocd_create_alb_ingress   = true
argocd_enable_notifications = true
argocd_enable_dex           = false

# Uncomment and configure if using ALB ingress
argocd_domain         = "argocd-nonprod-dev.ekspilot.com"
# argocd_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/xxx"
argocd_alb_scheme     = "internal"

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
