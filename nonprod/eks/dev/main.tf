################################################################################
# EKS Dev Cluster Configuration - NonProd Account
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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
# EKS Add-on IAM Roles Module
################################################################################

module "eks_addon_iam_roles" {
  source = "../../../modules/eks-addon-iam-roles"

  cluster_name = var.cluster_name

  # Enable the add-ons you need
  enable_efs_csi_driver = true
  enable_external_dns   = true

  # Restrict External DNS to specific hosted zones (optional)
  # external_dns_route53_zone_arns = [
  #   "arn:aws:route53:::hostedzone/Z1234567890ABC"
  # ]

  tags = var.tags

  # Module depends on EKS cluster being created first
  depends_on = [module.eks]
}

################################################################################
# Local Variables
################################################################################

locals {
  # Determine which default node pools to enable based on variable value
  default_node_pools = (
    lower(var.enable_default_node_pools) == "both" || lower(var.enable_default_node_pools) == "true" ? ["general-purpose", "system"] :
    lower(var.enable_default_node_pools) == "general-purpose" ? ["general-purpose"] :
    lower(var.enable_default_node_pools) == "system" ? ["system"] :
    [] # "none" or "false"
  )

  # Merge user-provided add-ons with required add-ons
  # Note: With Pod Identity, IAM roles are associated automatically via pod identity associations
  # No need to specify service_account_role_arn in the addon configuration
  cluster_addons = merge(
    var.cluster_addons,
    {
      # Amazon EFS CSI Driver - Enables dynamic provisioning of EFS volumes
      aws-efs-csi-driver = {
        most_recent = true
      }

      # External DNS - Automatically creates DNS records for services and ingresses  
      external-dns = {
        most_recent = true
      }
    }
  )
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.8"

  name             = var.cluster_name
  kubernetes_version  = var.cluster_version

  # EKS Upgrade Policy - Standard or Extended Support
  # Standard: 14 months of support (free)
  # Extended: Up to 26 months of support (additional cost)
  upgrade_policy = {
    support_type = var.cluster_upgrade_support_type
  }

  # Cluster endpoint access
  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  # Additional CIDR blocks that can access the cluster endpoint
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Use existing VPC
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Enable cluster creator admin permissions
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Enable EKS Auto Mode
  compute_config = {
    enabled    = true
    node_pools = local.default_node_pools
  }

  # Envelope encryption for Kubernetes secrets
  encryption_config = var.enable_secrets_encryption ? {
    provider_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].arn
    resources        = ["secrets"]
  } : null

  # Enable ARC Zonal Shift for improved availability
  # Allows AWS to automatically shift traffic away from impaired AZs
  zonal_shift_config = var.enable_zonal_shift ? {
    enabled = true
  } : null

  # Cluster deletion protection
  # Prevents accidental deletion of the EKS cluster via AWS Console or CLI
  # You can still destroy via Terraform (Terraform manages this setting)
  deletion_protection = var.enable_cluster_deletion_protection

  # Additional security groups to attach to the cluster
  additional_security_group_ids = var.additional_security_group_ids

  # Control plane logging to CloudWatch
  enabled_log_types              = var.enable_cluster_control_plane_logging ? var.cluster_enabled_log_types : []
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id   = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class     = var.cloudwatch_log_group_class

  
  # Cluster add-ons
  addons = local.cluster_addons

  tags = var.tags
}

################################################################################
# KMS Key for EKS Secrets Envelope Encryption (Optional)
################################################################################

resource "aws_kms_key" "eks" {
  count = var.enable_secrets_encryption && var.kms_key_arn == "" ? 1 : 0

  description             = "KMS key for EKS cluster ${var.cluster_name} secrets envelope encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_enable_key_rotation

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-secrets"
    }
  )
}