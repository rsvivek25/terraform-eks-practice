################################################################################
# ArgoCD Terraform Module
# Installs ArgoCD using Helm chart
################################################################################

################################################################################
# ArgoCD Namespace
################################################################################

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

################################################################################
# ArgoCD Helm Release
################################################################################

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Use templatefile for values if provided, otherwise use inline values
  values = var.values_file != "" ? [
    templatefile(var.values_file, var.values_template_vars)
  ] : [
    yamlencode({
      global = {
        domain = var.server_host
        # Global tolerations applied to all ArgoCD components including init jobs
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Controller
      controller = {
        replicas = var.ha_enabled ? var.replicas : 1
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Server
      server = {
        replicas = var.ha_enabled ? var.replicas : 1
        service = {
          type = var.server_service_type
        }
        ingress = {
          enabled = var.server_ingress_enabled
          hosts   = var.server_host != "" ? [var.server_host] : []
        }
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Repo Server
      repoServer = {
        replicas = var.ha_enabled ? var.replicas : 1
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # ApplicationSet Controller
      applicationSet = {
        replicas = var.ha_enabled ? var.replicas : 1
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Redis
      redis = {
        enabled = true
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Redis HA
      redis-ha = {
        enabled = var.redis_ha_enabled
        haproxy = {
          enabled = var.redis_ha_enabled
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            }
          ]
        }
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Notifications
      notifications = {
        enabled = var.enable_notifications
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Dex (SSO)
      dex = {
        enabled = var.enable_dex
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      }

      # Config
      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }
      }
    })
  ]

  # Additional custom values
  dynamic "set" {
    for_each = var.additional_set_values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}

################################################################################
# AWS Load Balancer Ingress (Optional)
################################################################################

resource "kubernetes_ingress_v1" "argocd_alb" {
  count = var.create_alb_ingress ? 1 : 0

  metadata {
    name      = "argocd-server-alb"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = merge(
      {
        "alb.ingress.kubernetes.io/scheme"      = var.alb_scheme
        "alb.ingress.kubernetes.io/target-type" = "ip"
        # Use HTTP backend protocol when server.insecure=true, otherwise HTTPS
        "alb.ingress.kubernetes.io/backend-protocol" = var.server_insecure ? "HTTP" : "HTTPS"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      },
      var.certificate_arn != "" ? {
        "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
        "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443}]"
        "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-TLS-1-2-2017-01"
      } : {
        "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}]"
      },
      var.alb_additional_annotations
    )
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.argocd_domain != "" ? var.argocd_domain : null
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                # Use port 80 when server.insecure=true, otherwise 443
                number = var.server_insecure ? 80 : 443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}
