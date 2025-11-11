# EKS Dev Cluster - NonProd

This directory contains the Terraform configuration for the EKS Dev cluster in the NonProd account.

## Prerequisites

1. **Bootstrap infrastructure** deployed (`nonprod/bootstrap`)
2. **EKS network** deployed (`nonprod/eks-network`)
3. VPC with private subnets across 3 availability zones
4. NAT Gateway for internet access

## What This Creates

- EKS cluster (Kubernetes 1.31) with Auto Mode
- KMS key for secrets encryption
- CloudWatch log group for control plane logs
- IAM roles for cluster and nodes
- EKS add-ons:
  - VPC CNI
  - kube-proxy
  - CoreDNS
  - Pod Identity Agent
  - EBS CSI Driver
- IAM role for AWS Load Balancer Controller (IRSA)

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
terraform output cluster_oidc_issuer_url
terraform output alb_controller_iam_role_arn
terraform output configure_kubectl
```

## Cleanup

To destroy the cluster:

```bash
# Delete all Kubernetes resources first (LoadBalancers, PVCs, etc.)
kubectl delete all --all --all-namespaces

# Then destroy with Terraform
terraform destroy -var-file=terraform.tfvars
```

## Troubleshooting

### Check Cluster Status

```bash
aws eks describe-cluster --name aws-blueprint-nonprod-dev --region us-east-1
```

### Check Add-on Status

```bash
aws eks list-addons --cluster-name aws-blueprint-nonprod-dev --region us-east-1
aws eks describe-addon --cluster-name aws-blueprint-nonprod-dev --addon-name vpc-cni --region us-east-1
```

### View Logs

```bash
aws logs tail /aws/eks/aws-blueprint-nonprod-dev/cluster --follow
```

## Cost Optimization

For dev/test environments, consider:

- Using spot instances in Auto Mode node pools (configure in cluster settings)
- Reducing log retention days (7 days for dev)
- Disabling unused add-ons
- Scheduling cluster downtime during non-working hours
