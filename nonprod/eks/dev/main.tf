################################################################################
# EKS Dev Cluster Configuration - NonProd Account
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
    bucket         = "eks-practice-nonprod-terraform-state-156041399540"
    key            = "eks/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-practice-nonprod-terraform-locks"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:156041399540:key/52bec355-a23b-4a51-92cd-764534449809"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "EKS-Dev"
      Account     = "nonprod"
      Cluster     = "dev"
    }
  }
}

################################################################################
# Data Sources
################################################################################

data "aws_caller_identity" "current" {}

################################################################################
# EKS Cluster Module
################################################################################

module "eks" {
  source = "../../../modules/eks"

  # Basic Cluster Configuration
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnet_ids

  # Network Configuration
  endpoint_private_access               = var.endpoint_private_access
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids

  # Auto Mode Configuration
  auto_mode_node_pools = var.auto_mode_node_pools

  # Encryption Configuration
  kms_key_arn                 = var.kms_key_arn
  kms_deletion_window_in_days = var.kms_deletion_window_in_days

  # Logging Configuration
  enabled_cluster_log_types              = var.enabled_cluster_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class

  # Access & Security Configuration
  authentication_mode                         = var.authentication_mode
  bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  enable_cluster_creator_admin_permissions    = var.enable_cluster_creator_admin_permissions
  enable_cluster_deletion_protection          = var.enable_cluster_deletion_protection

  # Add-ons & Advanced Configuration
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons
  support_type                  = var.support_type
  zonal_shift_enabled           = var.zonal_shift_enabled

  # Tags
  tags = var.tags
}
