################################################################################
# General Configuration
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "nonprod"
}

################################################################################
# Basic Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-nonprod-dev"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "cluster_upgrade_support_type" {
  description = "Support type for the cluster upgrade policy (STANDARD, EXTENDED)"
  type        = string
  default     = "STANDARD"
}

################################################################################
# Network Configuration
################################################################################

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS cluster"
  type        = list(string)
}

################################################################################
# Cluster Endpoint Access Configuration
################################################################################

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

################################################################################
# Auto Mode Configuration
################################################################################

variable "enable_default_node_pools" {
  description = "Enable default node pools for EKS Auto Mode (both, general-purpose, system, none, true, false)"
  type        = string
  default     = "both"
}

################################################################################
# Encryption Configuration
################################################################################

variable "enable_secrets_encryption" {
  description = "Enable envelope encryption for Kubernetes secrets"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for cluster encryption. If empty, a new key will be created"
  type        = string
  default     = ""
}

variable "kms_key_deletion_window" {
  description = "Duration in days after which the KMS key is deleted after destruction (7-30)"
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic key rotation for the KMS key"
  type        = bool
  default     = true
}

################################################################################
# Logging Configuration
################################################################################

variable "enable_cluster_control_plane_logging" {
  description = "Enable control plane logging to CloudWatch"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events in CloudWatch"
  type        = number
  default     = 7
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ID to encrypt CloudWatch log group"
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_class" {
  description = "CloudWatch log group class (STANDARD, INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"
}

################################################################################
# Access & Security Configuration
################################################################################

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to enable cluster creator with admin permissions"
  type        = bool
  default     = true
}

variable "additional_security_group_ids" {
  description = "List of additional security group IDs to attach to the cluster"
  type        = list(string)
  default     = []
}

variable "enable_cluster_deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

################################################################################
# Zonal Shift Configuration
################################################################################

variable "enable_zonal_shift" {
  description = "Enable ARC Zonal Shift for improved availability"
  type        = bool
  default     = true
}

################################################################################
# Cluster Add-ons
################################################################################

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable"
  type        = any
  default     = {}
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
