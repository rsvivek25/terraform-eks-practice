################################################################################
# ArgoCD Outputs
################################################################################

output "namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}

output "chart_version" {
  description = "ArgoCD Helm chart version installed"
  value       = helm_release.argocd.version
}

output "server_service_name" {
  description = "ArgoCD server Kubernetes service name"
  value       = "argocd-server"
}

output "server_service_namespace" {
  description = "Namespace of ArgoCD server service"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "initial_admin_secret_name" {
  description = "Name of the Kubernetes secret containing initial admin password"
  value       = "argocd-initial-admin-secret"
}

output "get_admin_password_command" {
  description = "Command to retrieve ArgoCD initial admin password"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "port_forward_command" {
  description = "Command to port-forward to ArgoCD server for local access"
  value       = "kubectl port-forward svc/argocd-server -n ${kubernetes_namespace.argocd.metadata[0].name} 8080:443"
}

output "access_url" {
  description = "URL to access ArgoCD"
  value       = var.create_alb_ingress && var.argocd_domain != "" ? "https://${var.argocd_domain}" : "https://localhost:8080 (use port-forward)"
}

output "alb_ingress_hostname" {
  description = "ALB ingress hostname (if created)"
  value       = var.create_alb_ingress ? try(kubernetes_ingress_v1.argocd_alb[0].status[0].load_balancer[0].ingress[0].hostname, "pending") : null
}

output "login_credentials" {
  description = "ArgoCD login information"
  value = {
    username                 = "admin"
    password_secret_name     = "argocd-initial-admin-secret"
    get_password_command     = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  }
  sensitive = false
}
