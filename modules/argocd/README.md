# ArgoCD Terraform Module

This module installs and configures ArgoCD on a Kubernetes cluster using the official Helm chart.

## Features

- ✅ High Availability mode with configurable replicas
- ✅ Redis HA for session storage
- ✅ AWS Load Balancer Controller integration (optional)
- ✅ Custom domain and SSL/TLS support
- ✅ SSO with Dex (optional)
- ✅ Notifications controller
- ✅ Flexible service types (LoadBalancer/ClusterIP/NodePort)

## Prerequisites

- Kubernetes cluster (EKS)
- Helm provider configured
- Kubernetes provider configured
- AWS Load Balancer Controller (if using ALB ingress)

## Usage

### Basic Installation

```hcl
module "argocd" {
  source = "../../../modules/argocd"

  namespace    = "argocd"
  chart_version = "7.7.12"
  
  # High Availability
  ha_enabled       = true
  replicas         = 2
  redis_ha_enabled = true

  # ClusterIP service (use port-forward for access)
  server_service_type = "ClusterIP"

  tags = {
    Environment = "nonprod"
    ManagedBy   = "Terraform"
  }
}
```

### With AWS Load Balancer

```hcl
module "argocd" {
  source = "../../../modules/argocd"

  namespace    = "argocd"
  ha_enabled   = true
  
  # ALB Ingress
  create_alb_ingress = true
  argocd_domain      = "argocd.example.com"
  certificate_arn    = "arn:aws:acm:us-east-1:123456789:certificate/xxx"
  alb_scheme         = "internet-facing"

  tags = var.tags
}
```

### Non-HA Single Instance

```hcl
module "argocd" {
  source = "../../../modules/argocd"

  namespace        = "argocd"
  ha_enabled       = false
  redis_ha_enabled = false

  tags = var.tags
}
```

## Accessing ArgoCD

### 1. Get Initial Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Or use PowerShell on Windows:

```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

### 2. Port Forward (for ClusterIP service)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then access: https://localhost:8080

### 3. Access via ALB (if configured)

If you created an ALB ingress with a custom domain, access via:
```
https://argocd.yourdomain.com
```

### 4. Login

- **Username**: `admin`
- **Password**: Retrieved from step 1

### 5. Change Admin Password

After first login, change the password:

```bash
argocd account update-password
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| helm | ~> 2.12 |
| kubernetes | ~> 2.25 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Kubernetes namespace for ArgoCD | `string` | `"argocd"` | no |
| chart_version | ArgoCD Helm chart version | `string` | `"7.7.12"` | no |
| ha_enabled | Enable High Availability mode | `bool` | `true` | no |
| replicas | Number of replicas when HA is enabled | `number` | `2` | no |
| redis_ha_enabled | Enable Redis HA | `bool` | `true` | no |
| server_service_type | Service type (LoadBalancer/ClusterIP/NodePort) | `string` | `"ClusterIP"` | no |
| create_alb_ingress | Create AWS Load Balancer ingress | `bool` | `false` | no |
| argocd_domain | Domain name for ArgoCD | `string` | `""` | no |
| certificate_arn | ACM certificate ARN for HTTPS | `string` | `""` | no |
| enable_notifications | Enable notifications controller | `bool` | `true` | no |
| enable_dex | Enable Dex for SSO | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace where ArgoCD is installed |
| server_service_name | ArgoCD server service name |
| get_admin_password_command | Command to retrieve admin password |
| port_forward_command | Command to port-forward for local access |
| access_url | URL to access ArgoCD |

## Examples

See the `nonprod/eks/dev/argocd.tf` file for a complete example.

## Notes

- The module uses `server.insecure = true` by default, which is suitable when running behind an ingress/load balancer that handles TLS
- For production environments, consider:
  - Using ALB with ACM certificate
  - Enabling Dex for SSO
  - Configuring backup strategies
  - Setting up monitoring and alerts
  - Using Git repository for declarative configuration
