################################################################################
# Required Variables
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
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

variable "enable_external_dns" {
  description = "Enable IAM role for External DNS add-on"
  type        = bool
  default     = false
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
