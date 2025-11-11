################################################################################
# EKS Auto Mode Cluster Module
# Creates an EKS cluster with Auto Mode enabled
################################################################################

################################################################################
# KMS Key for EKS Encryption (if not provided)
################################################################################

resource "aws_kms_key" "eks" {
  count = var.kms_key_arn == "" ? 1 : 0

  description             = "KMS key for EKS cluster ${var.cluster_name} encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-key"
    }
  )
}

resource "aws_kms_alias" "eks" {
  count = var.kms_key_arn == "" ? 1 : 0

  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks[0].key_id
}

################################################################################
# EKS Cluster with Auto Mode
################################################################################

resource "aws_eks_cluster" "main" {
  name    = var.cluster_name
  version = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = false
  }

  # Auto Mode Configuration
  compute_config {
    enabled    = true
    node_pools = var.auto_mode_node_pools
  }

  # Encryption Configuration
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].arn
    }
  }

  # Logging Configuration
  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Access Configuration
  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  # Deletion Protection
  deletion_protection = var.enable_cluster_deletion_protection

  # Additional Security Groups
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids

  # CloudWatch Log Group Configuration
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class

  # Self-Managed Add-ons
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  # Storage Configuration
  storage_config {
    block_storage {
      enabled = true
    }
  }

  # Kubernetes Network Configuration
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  # Upgrade Policy
  upgrade_policy {
    support_type = var.support_type
  }

  # Zonal Shift Configuration
  zonal_shift_config {
    enabled = var.zonal_shift_enabled
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

################################################################################
# Data Sources
################################################################################

data "aws_caller_identity" "current" {}
