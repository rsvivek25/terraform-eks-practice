################################################################################
# EKS Auto Mode Cluster Module Wrapper
# Wraps terraform-aws-modules/eks/aws with Auto Mode configuration
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  # Basic Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network Configuration
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # Cluster Endpoint Access
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = var.endpoint_private_access

  # Additional Security Groups
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids

  # Auto Mode Configuration
  cluster_compute_config = {
    enabled    = true
    node_pools = var.auto_mode_node_pools
  }

  # Encryption Configuration
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  create_kms_key                  = var.kms_key_arn == "" ? true : false
  kms_key_description             = "KMS key for EKS cluster ${var.cluster_name} encryption"
  kms_key_deletion_window_in_days = var.kms_deletion_window_in_days
  enable_kms_key_rotation         = true

  # Logging Configuration
  cluster_enabled_log_types = var.enabled_cluster_log_types

  # Access Configuration
  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions

  # Deletion Protection
  cluster_deletion_protection = var.enable_cluster_deletion_protection

  # Upgrade Policy
  cluster_upgrade_policy = {
    support_type = var.support_type
  }

  # Zonal Shift Configuration
  cluster_zonal_shift_config = {
    enabled = var.zonal_shift_enabled
  }

  # Tags
  tags = var.tags
}
