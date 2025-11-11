################################################################################
# ALB Ingress Class Module Outputs
################################################################################

output "ingress_class_name" {
  description = "Name of the created IngressClass"
  value       = var.ingress_class_name
}

output "alb_scheme" {
  description = "ALB scheme (internal or internet-facing)"
  value       = var.alb_scheme
}

output "subnet_ids" {
  description = "Subnet IDs used for ALB deployment"
  value       = var.subnet_ids
}
