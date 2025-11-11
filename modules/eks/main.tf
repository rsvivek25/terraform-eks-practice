################################################################################
# EKS Auto Mode Cluster Module Wrapper
# Wraps terraform-aws-modules/eks/aws with Auto Mode configuration
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  # Basic Cluster Configuration
  name    = var.cluster_name
  version = var.cluster_version

  # Network Configuration
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # Cluster Endpoint Access
  endpoint_public_access  = false
  endpoint_private_access = var.endpoint_private_access

  # Additional Security Groups
  additional_security_group_ids = var.cluster_additional_security_group_ids

  # Auto Mode Configuration
  compute_config = {
    enabled    = true
    node_pools = var.auto_mode_node_pools
  }

  # Encryption Configuration
  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  create_kms_key                  = var.kms_key_arn == "" ? true : false
  kms_key_description             = "KMS key for EKS cluster ${var.cluster_name} encryption"
  kms_key_deletion_window_in_days = var.kms_deletion_window_in_days
  enable_kms_key_rotation         = true

  # Logging Configuration
  enabled_log_types = var.enabled_cluster_log_types

  # Access Configuration
  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = true

  # Deletion Protection
  cluster_deletion_protection = var.enable_cluster_deletion_protection

  # Upgrade Policy
  cluster_upgrade_policy = {
    support_type = var.support_type
  }

  # Zonal Shift Configuration
  zonal_shift_config = {
    enabled = var.zonal_shift_enabled
  }

  # Tags
  tags = var.tags
}
