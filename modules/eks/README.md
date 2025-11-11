# EKS Auto Mode Cluster Module

This module creates an Amazon EKS cluster with Auto Mode enabled, providing fully managed compute infrastructure.

## Features

- **Auto Mode**: Fully managed node pools with automatic scaling
- **Security**: KMS encryption for secrets, OIDC provider, IAM roles
- **Logging**: CloudWatch Logs for control plane
- **Add-ons**: VPC CNI, kube-proxy, CoreDNS, Pod Identity, EBS CSI Driver
- **High Availability**: Zonal shift support, multi-AZ deployment
- **Access Control**: Configurable public/private API endpoint access

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"
  subnet_ids      = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]

  # Auto Mode Configuration
  auto_mode_node_pools = ["general-purpose"]

  # Access Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  log_retention_days        = 7

  # Add-ons
  enable_vpc_cni_addon        = true
  enable_kube_proxy_addon     = true
  enable_coredns_addon        = true
  enable_pod_identity_addon   = true
  enable_ebs_csi_driver_addon = true
  enable_alb_controller       = true

  tags = {
    Environment = "nonprod"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the EKS cluster | string | - | yes |
| cluster_version | Kubernetes version | string | "1.31" | no |
| subnet_ids | List of subnet IDs for cluster | list(string) | - | yes |
| endpoint_private_access | Enable private API endpoint | bool | true | no |
| endpoint_public_access | Enable public API endpoint | bool | true | no |
| public_access_cidrs | CIDRs for public endpoint access | list(string) | ["0.0.0.0/0"] | no |
| auto_mode_node_pools | Node pools for Auto Mode | list(string) | ["general-purpose"] | no |
| kms_key_arn | KMS key ARN for encryption | string | "" | no |
| enabled_cluster_log_types | Control plane log types | list(string) | all types | no |
| log_retention_days | CloudWatch log retention days | number | 7 | no |
| enable_vpc_cni_addon | Enable VPC CNI add-on | bool | true | no |
| enable_kube_proxy_addon | Enable kube-proxy add-on | bool | true | no |
| enable_coredns_addon | Enable CoreDNS add-on | bool | true | no |
| enable_pod_identity_addon | Enable Pod Identity add-on | bool | true | no |
| enable_ebs_csi_driver_addon | Enable EBS CSI driver | bool | true | no |
| enable_alb_controller | Enable ALB Controller IAM role | bool | true | no |
| zonal_shift_enabled | Enable zonal shift | bool | true | no |
| tags | Additional resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_name | EKS cluster name |
| cluster_arn | EKS cluster ARN |
| cluster_endpoint | EKS cluster API endpoint |
| cluster_version | Kubernetes version |
| cluster_oidc_issuer_url | OIDC issuer URL |
| cluster_iam_role_arn | Cluster IAM role ARN |
| node_iam_role_arn | Node IAM role ARN |
| alb_controller_iam_role_arn | ALB Controller IAM role ARN |
| kms_key_arn | KMS key ARN |
| cloudwatch_log_group_name | CloudWatch log group name |

## Auto Mode Node Pools

Auto Mode supports the following node pools:

- `general-purpose` - Balanced compute, memory, and network resources
- `system` - Optimized for system workloads
- `compute-optimized` - High CPU-to-memory ratio
- `memory-optimized` - High memory-to-CPU ratio

## Add-ons

The module installs the following EKS add-ons:

1. **VPC CNI** - Pod networking
2. **kube-proxy** - Network proxy
3. **CoreDNS** - DNS server
4. **Pod Identity** - IAM roles for service accounts
5. **EBS CSI Driver** - Persistent volume support

## Security

- KMS encryption for Kubernetes secrets
- IAM roles with least privilege
- Private/public endpoint control
- Security groups managed by EKS
- OIDC provider for IRSA

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- VPC with subnets in multiple AZs
- Appropriate IAM permissions
