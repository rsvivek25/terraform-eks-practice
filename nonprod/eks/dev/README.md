# EKS Dev Cluster - NonProd

This directory contains the Terraform configuration for the EKS Dev cluster in the NonProd account.

## Prerequisites

1. **Bootstrap infrastructure** deployed (`nonprod/bootstrap`)
2. **EKS network** deployed (`nonprod/eks-network`)
3. VPC with private subnets across 3 availability zones
4. NAT Gateway for internet access

## What This Creates

- **EKS Cluster** (Kubernetes 1.33) with Auto Mode
- **Encryption**: KMS key for secrets encryption
- **Logging**: CloudWatch log group for control plane logs
- **IAM Roles**: 
  - Cluster and node roles with least privilege
  - Pod Identity roles for EFS CSI Driver and External DNS
- **EKS Add-ons**:
  - VPC CNI
  - kube-proxy
  - CoreDNS
  - Pod Identity Agent
  - EBS CSI Driver
  - **AWS EFS CSI Driver** (with Pod Identity)
  - **External DNS** (with Pod Identity)
- **ArgoCD**:
  - GitOps continuous delivery tool
  - High Availability setup (configurable)
  - Notifications controller
  - Redis HA for session storage

## Configuration Steps

### 1. Get Subnet IDs from EKS Network

```bash
cd ../../eks-network
terraform output eks_subnet_ids
```

### 2. Update terraform.tfvars

Edit `terraform.tfvars` and update the subnet IDs:

```hcl
subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxxx",  # Replace with actual subnet IDs
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-xxxxxxxxxxxxxxxxx"
]
```

### 3. Review Configuration

Review other settings in `terraform.tfvars`:
- Cluster version
- Auto Mode node pools
- Logging configuration
- Add-on settings
- Access controls

### 4. Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

## Post-Deployment

### Configure kubectl

After deployment, configure kubectl to access the cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name aws-blueprint-nonprod-dev
```

### Verify Cluster

```bash
# Check cluster status
kubectl cluster-info

# Check nodes (Auto Mode nodes)
kubectl get nodes

# Check add-ons
kubectl get pods -n kube-system

# Check namespaces
kubectl get namespaces
```

### Install AWS Load Balancer Controller (Optional)

If you enabled the ALB controller IAM role, install the controller:

```bash
# Add helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Get IAM role ARN from outputs
terraform output alb_controller_iam_role_arn

# Install the controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=aws-blueprint-nonprod-dev \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="<IAM_ROLE_ARN>"
```

## Auto Mode

This cluster uses EKS Auto Mode with the `general-purpose` node pool. Auto Mode automatically:

- Provisions and manages compute resources
- Scales nodes based on workload requirements
- Handles node lifecycle management
- Optimizes cost and performance

You don't need to manage node groups or Fargate profiles.

## Security

- **Encryption**: Kubernetes secrets encrypted with KMS
- **Network**: Cluster deployed in private subnets
- **Access**: API endpoint supports both public and private access
- **IAM**: Separate roles for cluster and nodes with least privilege
- **Logging**: All control plane logs sent to CloudWatch

## Outputs

After deployment, useful outputs:

```bash
terraform output cluster_endpoint
terraform output cluster_name
terraform output configure_kubectl
terraform output argocd_namespace
terraform output argocd_access_url
terraform output argocd_initial_admin_password_command
```

## ArgoCD Access

### Get Initial Admin Password

**Linux/macOS:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

**Windows PowerShell:**
```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

### Access ArgoCD UI

1. **Port Forward to ArgoCD Server:**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. **Open Browser:**
   Navigate to https://localhost:8080

3. **Login:**
   - Username: `admin`
   - Password: (from command above)

4. **Change Password (Recommended):**
   ```bash
   argocd account update-password
   ```

### ArgoCD CLI Installation (Optional)

**Linux:**
```bash
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/
```

**macOS:**
```bash
brew install argocd
```

**Windows:**
```powershell
# Using Chocolatey
choco install argocd-cli

# Or download from releases page
# https://github.com/argoproj/argo-cd/releases
```

## Cleanup

To destroy the cluster:

```bash
# 1. Delete all ArgoCD applications first
kubectl delete applications --all -n argocd

# 2. Delete all Kubernetes resources (LoadBalancers, PVCs, etc.)
kubectl delete all --all --all-namespaces

# 3. Uninstall ArgoCD (optional, Terraform will handle it)
helm uninstall argocd -n argocd

# 4. Destroy with Terraform
terraform destroy -var-file=terraform.tfvars
```

## Troubleshooting

### Check Cluster Status

```bash
aws eks describe-cluster --name eks-nonprod-dev --region us-east-1
```

### Check Add-on Status

```bash
aws eks list-addons --cluster-name eks-nonprod-dev --region us-east-1
aws eks describe-addon --cluster-name eks-nonprod-dev --addon-name aws-efs-csi-driver --region us-east-1
```

### View Logs

```bash
aws logs tail /aws/eks/eks-nonprod-dev/cluster --follow
```

### ArgoCD Troubleshooting

**Check ArgoCD Pods:**
```bash
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-server
```

**Check ArgoCD Application Status:**
```bash
argocd app list
argocd app get <app-name>
```

**Sync ArgoCD Application:**
```bash
argocd app sync <app-name>
```

## Cost Optimization

For dev/test environments, consider:

- Using spot instances in Auto Mode node pools (configure in cluster settings)
- Reducing log retention days (7 days for dev)
- Disabling unused add-ons
- Scheduling cluster downtime during non-working hours
- Disable ArgoCD HA mode for non-production (set `argocd_ha_enabled = false`)
