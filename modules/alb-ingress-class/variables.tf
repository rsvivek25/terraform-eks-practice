################################################################################
# ALB Ingress Class Module Variables
################################################################################

variable "ingress_class_name" {
  description = "Name of the IngressClass and IngressClassParams"
  type        = string
  default     = "alb"
}

variable "alb_scheme" {
  description = "ALB scheme: internal or internet-facing"
  type        = string
  default     = "internal"
  
  validation {
    condition     = contains(["internal", "internet-facing"], var.alb_scheme)
    error_message = "ALB scheme must be either 'internal' or 'internet-facing'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs where ALB will be deployed"
  type        = list(string)
}

variable "is_default_class" {
  description = "Set this IngressClass as the default for the cluster"
  type        = bool
  default     = true
}

variable "alb_tags" {
  description = "Additional tags to apply to the ALB (optional)"
  type        = map(string)
  default     = null
}
