################################################################################
# Required Variables
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
}

################################################################################
# Add-on Enable/Disable Flags
################################################################################

variable "enable_efs_csi_driver" {
  description = "Enable IAM role for EFS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "efs_csi_driver_version" {
  description = "Version of EFS CSI Driver add-on. If empty, uses the latest version"
  type        = string
  default     = ""
}

variable "enable_external_dns" {
  description = "Enable IAM role for External DNS add-on"
  type        = bool
  default     = false
}

variable "external_dns_version" {
  description = "Version of External DNS add-on. If empty, uses the latest version"
  type        = string
  default     = ""
}

################################################################################
# External DNS Configuration
################################################################################

variable "external_dns_route53_zone_arns" {
  description = "List of Route53 hosted zone ARNs that External DNS can manage. Use ['arn:aws:route53:::hostedzone/*'] for all zones"
  type        = list(string)
  default     = ["arn:aws:route53:::hostedzone/*"]
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
