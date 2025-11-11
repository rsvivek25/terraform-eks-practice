################################################################################
# ALB Ingress Class Configuration for Dev Cluster
################################################################################

module "alb_ingress_class" {
  source = "../../../modules/alb-ingress-class"

  ingress_class_name = "alb"
  alb_scheme         = "internal"  # Internal ALB - accessible only within VPC
  subnet_ids         = var.private_subnet_ids
  is_default_class   = true  # Set as default IngressClass

  # Optional: Add tags to ALBs created by this IngressClass
  alb_tags = {
    Environment = var.environment
    Cluster     = var.cluster_name
  }

  # Ensure EKS cluster is created first
  depends_on = [module.eks]
}
