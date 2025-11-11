################################################################################
# Basic Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster (private subnets recommended)"
  type        = list(string)
}

################################################################################
# Network Configuration
################################################################################

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

################################################################################
# Auto Mode Configuration
################################################################################

variable "auto_mode_node_pools" {
  description = "List of node pools for EKS Auto Mode"
  type        = list(string)
  default     = ["general-purpose"]
}

################################################################################
# Encryption Configuration
################################################################################

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for cluster encryption. If empty, a new key will be created"
  type        = string
  default     = ""
}

variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the KMS key is deleted after destruction (7-30)"
  type        = number
  default     = 30
}

################################################################################
# Logging Configuration
################################################################################

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain cluster logs in CloudWatch"
  type        = number
  default     = 7
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ID to use for CloudWatch log group encryption. If not specified, uses the KMS key for cluster encryption"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_class" {
  description = "Log class for the CloudWatch log group. Valid values are STANDARD or INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloudwatch_log_group_class)
    error_message = "cloudwatch_log_group_class must be STANDARD or INFREQUENT_ACCESS"
  }
}

################################################################################
# Access & Security Configuration
################################################################################

variable "authentication_mode" {
  description = "Authentication mode for the cluster (API, API_AND_CONFIG_MAP, CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP", "CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be API, API_AND_CONFIG_MAP, or CONFIG_MAP"
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator with admin permissions"
  type        = bool
  default     = true
}

variable "enable_cluster_deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

################################################################################
# Add-ons & Advanced Configuration
################################################################################

variable "bootstrap_self_managed_addons" {
  description = "Whether to bootstrap self-managed add-ons"
  type        = bool
  default     = false
}

variable "support_type" {
  description = "Support type for the cluster (STANDARD, EXTENDED)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "support_type must be STANDARD or EXTENDED"
  }
}

variable "zonal_shift_enabled" {
  description = "Enable zonal shift for the cluster"
  type        = bool
  default     = true
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
