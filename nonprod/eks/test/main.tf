################################################################################
# EKS Cluster Configuration - NonProd Test
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure these values after bootstrap
    # bucket         = "aws-blueprint-nonprod-terraform-state-<account-id>"
    # key            = "eks/test/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "aws-blueprint-nonprod-terraform-locks"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "EKS"
      Account     = "nonprod"
      Cluster     = "test"
    }
  }
}

################################################################################
# Data Sources
################################################################################

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Type = "private"
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source = "../../../modules/eks"

  # Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC Configuration
  subnet_ids              = var.subnet_ids
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  # Auto Mode Configuration
  auto_mode_node_pools = var.auto_mode_node_pools

  # Encryption Configuration
  kms_key_arn                 = var.kms_key_arn
  kms_deletion_window_in_days = var.kms_deletion_window_in_days

  # Logging Configuration
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = var.log_retention_days

  # Access Configuration
  authentication_mode                         = var.authentication_mode
  bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions

  # Add-ons Configuration
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  # Support Configuration
  support_type = var.support_type

  # Zonal Shift Configuration
  zonal_shift_enabled = var.zonal_shift_enabled

  # Add-on Versions
  enable_vpc_cni_addon   = var.enable_vpc_cni_addon
  vpc_cni_addon_version  = var.vpc_cni_addon_version
  enable_kube_proxy_addon = var.enable_kube_proxy_addon
  kube_proxy_addon_version = var.kube_proxy_addon_version
  enable_coredns_addon    = var.enable_coredns_addon
  coredns_addon_version   = var.coredns_addon_version
  enable_pod_identity_addon = var.enable_pod_identity_addon
  pod_identity_addon_version = var.pod_identity_addon_version
  enable_ebs_csi_driver_addon = var.enable_ebs_csi_driver_addon
  ebs_csi_driver_addon_version = var.ebs_csi_driver_addon_version
  enable_alb_controller = var.enable_alb_controller

  # Tags
  tags = merge(
    var.tags,
    {
      Cluster = "test"
    }
  )
}
