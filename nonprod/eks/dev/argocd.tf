################################################################################
# ArgoCD Installation for Dev Cluster
################################################################################

################################################################################
# Helm Provider Configuration
################################################################################

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

################################################################################
# Kubernetes Provider Configuration
################################################################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

################################################################################
# ArgoCD Module
################################################################################

module "argocd" {
  source = "../../../modules/argocd"

  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version

  # High Availability Configuration
  ha_enabled       = var.argocd_ha_enabled
  replicas         = var.argocd_replicas
  redis_ha_enabled = var.argocd_redis_ha_enabled

  # Server Configuration
  server_service_type = var.argocd_server_service_type
  server_host         = var.argocd_server_host
  server_insecure     = var.argocd_server_insecure

  # AWS Load Balancer Configuration (optional)
  create_alb_ingress = var.argocd_create_alb_ingress
  argocd_domain      = var.argocd_domain
  certificate_arn    = var.argocd_certificate_arn
  alb_scheme         = var.argocd_alb_scheme

  # Features
  enable_notifications = var.argocd_enable_notifications
  enable_dex           = var.argocd_enable_dex

  tags = var.tags

  # Ensure EKS cluster is created first
  depends_on = [module.eks]
}
