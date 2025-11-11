# ArgoCD Installation Quick Start

This guide will help you install ArgoCD on your EKS cluster using Terraform.

## What Was Added

### Module Structure
```
modules/argocd/
├── main.tf           # ArgoCD Helm installation
├── variables.tf      # Configuration variables
├── outputs.tf        # Module outputs
└── README.md         # Module documentation
```

### Dev Environment Files
```
nonprod/eks/dev/
├── argocd.tf         # ArgoCD module configuration
├── main.tf           # Updated with Helm/Kubernetes providers
├── variables.tf      # Added ArgoCD variables
├── terraform.tfvars  # Added ArgoCD configuration
└── outputs.tf        # Added ArgoCD outputs
```

## Installation Steps

### 1. Initialize Terraform with New Providers

```powershell
cd nonprod/eks/dev
terraform init -upgrade
```

This will download the new Helm and Kubernetes providers.

### 2. Review the Plan

```powershell
terraform plan
```

You should see:
- Helm provider configuration
- Kubernetes provider configuration
- ArgoCD namespace creation
- ArgoCD Helm release
- ArgoCD outputs

### 3. Apply the Configuration

```powershell
terraform apply
```

This will:
1. Configure Helm and Kubernetes providers (using AWS EKS authentication)
2. Create the `argocd` namespace
3. Install ArgoCD via Helm chart (version 7.7.12)
4. Set up High Availability with 2 replicas
5. Configure Redis HA for session storage

### 4. Wait for ArgoCD Pods to be Ready

```bash
kubectl get pods -n argocd --watch
```

Wait until all pods show `Running` status (typically 2-3 minutes).

### 5. Get ArgoCD Admin Password

**Windows PowerShell:**
```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

**Git Bash/Linux:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Save this password - you'll need it to login!

### 6. Access ArgoCD UI

**Option A: Port Forward (Recommended for First Access)**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open: https://localhost:8080

**Option B: Get from Terraform Outputs**
```powershell
terraform output argocd_port_forward_command
terraform output argocd_initial_admin_password_command
```

### 7. Login to ArgoCD

- **URL**: https://localhost:8080
- **Username**: `admin`
- **Password**: (from step 5)

**Important**: Accept the self-signed certificate warning in your browser.

### 8. Change Admin Password (Recommended)

After first login, change your password via the UI:
1. Click on "User Info" (top left)
2. Click "Update Password"
3. Enter current and new password

Or use ArgoCD CLI:
```bash
argocd account update-password
```

## Configuration Options

### Current Configuration (terraform.tfvars)

```hcl
argocd_namespace            = "argocd"
argocd_chart_version        = "7.7.12"
argocd_ha_enabled           = true          # High Availability enabled
argocd_replicas             = 2              # 2 replicas of each component
argocd_redis_ha_enabled     = true          # Redis HA enabled
argocd_server_service_type  = "ClusterIP"   # Internal service (use port-forward)
argocd_server_insecure      = true          # HTTP mode (OK behind ingress)
argocd_create_alb_ingress   = false         # No ALB ingress yet
argocd_enable_notifications = true          # Notifications enabled
argocd_enable_dex           = false         # SSO disabled (can enable later)
```

### Enable AWS Load Balancer (Optional)

To expose ArgoCD via ALB, update `terraform.tfvars`:

```hcl
argocd_create_alb_ingress = true
argocd_domain             = "argocd.yourdomain.com"
argocd_certificate_arn    = "arn:aws:acm:us-east-1:123456789:certificate/xxx"
argocd_alb_scheme         = "internet-facing"  # or "internal"
```

Then run:
```powershell
terraform apply
```

### Disable High Availability (Cost Savings for Dev)

For development environments, you can run a single instance:

```hcl
argocd_ha_enabled       = false
argocd_replicas         = 1
argocd_redis_ha_enabled = false
```

This reduces resource usage significantly.

## Verification

### Check All Components

```bash
# Check pods
kubectl get pods -n argocd

# Check services
kubectl get svc -n argocd

# Check Helm release
helm list -n argocd
```

Expected pods:
- `argocd-server-*` (2 replicas)
- `argocd-repo-server-*` (2 replicas)
- `argocd-application-controller-*` (2 replicas)
- `argocd-applicationset-controller-*` (2 replicas)
- `argocd-notifications-controller-*` (1 replica)
- `argocd-redis-ha-haproxy-*` (3 replicas)
- `argocd-redis-ha-server-*` (3 replicas)

### View Terraform Outputs

```powershell
terraform output argocd_namespace
terraform output argocd_chart_version
terraform output argocd_access_url
terraform output argocd_login_info
```

## Next Steps

1. **Install ArgoCD CLI** (optional but recommended):
   - Windows: `choco install argocd-cli`
   - macOS: `brew install argocd`
   - Linux: Download from [releases](https://github.com/argoproj/argo-cd/releases)

2. **Connect Your Git Repository**:
   - Add repository in ArgoCD UI: Settings → Repositories
   - Or use CLI: `argocd repo add <repo-url>`

3. **Create Your First Application**:
   - Use UI: New App button
   - Or use CLI: `argocd app create`
   - Or use declarative: Apply Application manifest

4. **Enable Notifications** (optional):
   - Configure Slack/Email in `argocd-notifications-cm` ConfigMap
   - See: https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/

5. **Configure SSO** (optional):
   - Set `argocd_enable_dex = true`
   - Configure Dex for GitHub/Google/SAML
   - See: https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod <pod-name> -n argocd
kubectl logs <pod-name> -n argocd
```

### Cannot Access UI

Check port-forward is running:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Forgot Admin Password

Reset it:
```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
kubectl -n argocd rollout restart deployment argocd-server
```

Wait for pods to restart, then get new password from the secret.

### Helm Release Issues

```bash
helm list -n argocd
helm status argocd -n argocd
helm get values argocd -n argocd
```

## Cleanup

To remove ArgoCD:

```powershell
# Option 1: Via Terraform (recommended)
terraform destroy -target=module.argocd

# Option 2: Via Helm
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [GitOps Patterns](https://www.gitops.tech/)
