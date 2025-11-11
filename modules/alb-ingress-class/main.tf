################################################################################
# ALB Ingress Class Module
# Creates IngressClass and IngressClassParams for AWS Load Balancer Controller
################################################################################

################################################################################
# IngressClassParams - Configures ALB behavior
################################################################################

resource "kubectl_manifest" "alb_ingress_class_params" {
  yaml_body = yamlencode({
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "IngressClassParams"
    
    metadata = {
      name = var.ingress_class_name
    }
    
    spec = {
      # ALB scheme: internal or internet-facing
      scheme = var.alb_scheme
      
      # Subnet selection for ALB
      subnets = {
        ids = var.subnet_ids
      }
      
      # Optional: Additional tags for ALB
      tags = var.alb_tags != null ? [
        for key, value in var.alb_tags : {
          key   = key
          value = value
        }
      ] : null
    }
  })
}

################################################################################
# IngressClass - Defines the ALB controller
################################################################################

resource "kubectl_manifest" "alb_ingress_class" {
  yaml_body = yamlencode({
    apiVersion = "networking.k8s.io/v1"
    kind       = "IngressClass"
    
    metadata = {
      name = var.ingress_class_name
      annotations = {
        # Set as default IngressClass if enabled
        "ingressclass.kubernetes.io/is-default-class" = tostring(var.is_default_class)
      }
    }
    
    spec = {
      # Configures the IngressClass to use EKS Auto Mode ALB controller
      controller = "eks.amazonaws.com/alb"
      
      parameters = {
        apiGroup = "eks.amazonaws.com"
        kind     = "IngressClassParams"
        name     = var.ingress_class_name
      }
    }
  })

  # Ensure IngressClassParams is created first
  depends_on = [kubectl_manifest.alb_ingress_class_params]
}
