################################################################################
# Required Variables
################################################################################

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "8.0.0" # Latest stable as of Nov 2025
}

################################################################################
# High Availability Configuration
################################################################################

variable "ha_enabled" {
  description = "Enable High Availability mode for ArgoCD components"
  type        = bool
  default     = true
}

variable "replicas" {
  description = "Number of replicas for ArgoCD components when HA is enabled"
  type        = number
  default     = 2

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "Replicas must be between 1 and 10."
  }
}

variable "redis_ha_enabled" {
  description = "Enable Redis HA for session storage"
  type        = bool
  default     = true
}

################################################################################
# Server Configuration
################################################################################

variable "server_service_type" {
  description = "Kubernetes service type for ArgoCD server (LoadBalancer/ClusterIP/NodePort)"
  type        = string
  default     = "ClusterIP"

  validation {
    condition     = contains(["LoadBalancer", "ClusterIP", "NodePort"], var.server_service_type)
    error_message = "Service type must be LoadBalancer, ClusterIP, or NodePort."
  }
}

variable "server_host" {
  description = "Hostname for ArgoCD server"
  type        = string
  default     = ""
}

variable "server_ingress_enabled" {
  description = "Enable ingress for ArgoCD server (managed by Helm chart)"
  type        = bool
  default     = false
}

variable "server_insecure" {
  description = "Run server without TLS (useful behind ingress/load balancer)"
  type        = bool
  default     = true
}

################################################################################
# AWS Load Balancer Configuration
################################################################################

variable "create_alb_ingress" {
  description = "Create AWS Load Balancer ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "argocd_domain" {
  description = "Domain name for ArgoCD (used with ALB ingress)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (leave empty for HTTP)"
  type        = string
  default     = ""
}

variable "alb_scheme" {
  description = "ALB scheme (internet-facing or internal)"
  type        = string
  default     = "internet-facing"

  validation {
    condition     = contains(["internet-facing", "internal"], var.alb_scheme)
    error_message = "ALB scheme must be internet-facing or internal."
  }
}

variable "alb_additional_annotations" {
  description = "Additional annotations for ALB ingress"
  type        = map(string)
  default     = {}
}

################################################################################
# Features Configuration
################################################################################

variable "enable_notifications" {
  description = "Enable ArgoCD notifications controller"
  type        = bool
  default     = true
}

variable "enable_dex" {
  description = "Enable Dex for SSO authentication"
  type        = bool
  default     = false
}

################################################################################
# Custom Values
################################################################################

variable "values_file" {
  description = "Path to custom Helm values template file"
  type        = string
  default     = ""
}

variable "values_template_vars" {
  description = "Variables to pass to values template file"
  type        = map(string)
  default     = {}
}

variable "additional_set_values" {
  description = "Additional Helm set values (key-value pairs)"
  type        = map(string)
  default     = {}
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
