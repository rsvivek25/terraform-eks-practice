variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-blueprint"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "nonprod"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "aws-blueprint-nonprod-dev"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster (private subnets recommended)"
  type        = list(string)
}

# VPC Configuration
variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Auto Mode Configuration
variable "auto_mode_node_pools" {
  description = "List of node pools for EKS Auto Mode"
  type        = list(string)
  default     = ["general-purpose"]
}

# Encryption Configuration
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

# Logging Configuration
variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain cluster logs in CloudWatch"
  type        = number
  default     = 7
}

# Access Configuration
variable "authentication_mode" {
  description = "Authentication mode for the cluster (API, API_AND_CONFIG_MAP, CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to bootstrap cluster creator with admin permissions"
  type        = bool
  default     = true
}

# Add-ons Configuration
variable "bootstrap_self_managed_addons" {
  description = "Whether to bootstrap self-managed add-ons"
  type        = bool
  default     = false
}

# Support Configuration
variable "support_type" {
  description = "Support type for the cluster (STANDARD, EXTENDED)"
  type        = string
  default     = "STANDARD"
}

# Zonal Shift Configuration
variable "zonal_shift_enabled" {
  description = "Enable zonal shift for the cluster"
  type        = bool
  default     = true
}

# Add-on Versions
variable "enable_vpc_cni_addon" {
  description = "Enable VPC CNI add-on"
  type        = bool
  default     = true
}

variable "vpc_cni_addon_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
  default     = null
}

variable "enable_kube_proxy_addon" {
  description = "Enable kube-proxy add-on"
  type        = bool
  default     = true
}

variable "kube_proxy_addon_version" {
  description = "Version of the kube-proxy add-on"
  type        = string
  default     = null
}

variable "enable_coredns_addon" {
  description = "Enable CoreDNS add-on"
  type        = bool
  default     = true
}

variable "coredns_addon_version" {
  description = "Version of the CoreDNS add-on"
  type        = string
  default     = null
}

variable "enable_pod_identity_addon" {
  description = "Enable EKS Pod Identity add-on"
  type        = bool
  default     = true
}

variable "pod_identity_addon_version" {
  description = "Version of the EKS Pod Identity add-on"
  type        = string
  default     = null
}

variable "enable_ebs_csi_driver_addon" {
  description = "Enable EBS CSI driver add-on"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_addon_version" {
  description = "Version of the EBS CSI driver add-on"
  type        = string
  default     = null
}

variable "enable_alb_controller" {
  description = "Enable AWS Load Balancer Controller IAM role"
  type        = bool
  default     = true
}

variable "enable_secrets_encryption" {
  description = "Enable envelope encryption for Kubernetes secrets"
  type        = bool
  default     = true
}

variable "enable_cluster_deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = true
}

variable "enable_cluster_control_plane_logging" {
  description = "Enable control plane logging to CloudWatch"
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_zonal_shift" {
  description = "Enable ARC Zonal Shift for improved availability"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
