# EKS Module

This module provisions an Amazon EKS cluster with EKS Auto Mode, comprehensive security features, and essential add-ons.

## Features

- **EKS Auto Mode**: Automated node provisioning and management
- **Security**: KMS encryption for secrets, OIDC provider for IRSA, comprehensive IAM roles
- **Observability**: CloudWatch logging for control plane, configurable log retention
- **High Availability**: Multi-AZ deployment support, zonal shift capability
- **Add-ons**: VPC CNI, kube-proxy, CoreDNS, Pod Identity, EBS CSI Driver
- **Load Balancing**: AWS Load Balancer Controller IAM role configuration

## Usage

```hcl
module "eks" {
  source = "../../../modules/eks"

  # Cluster Configuration
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  # VPC Configuration
  subnet_ids              = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Auto Mode Configuration
  auto_mode_node_pools = ["general-purpose"]

  # Encryption Configuration
  kms_key_arn                 = ""  # Empty creates new key
  kms_deletion_window_in_days = 30

  # Logging Configuration
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  log_retention_days        = 7

  # Access Configuration
  authentication_mode                         = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true

  # Add-ons Configuration
  enable_vpc_cni_addon        = true
  enable_kube_proxy_addon     = true
  enable_coredns_addon        = true
  enable_pod_identity_addon   = true
  enable_ebs_csi_driver_addon = true
  enable_alb_controller       = true

  # Support Configuration
  support_type = "STANDARD"

  # Zonal Shift Configuration
  zonal_shift_enabled = true

  # Tags
  tags = {
    Environment = "nonprod"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| tls | n/a |

## Resources Created

- EKS Cluster with Auto Mode
- KMS Key for encryption (if kms_key_arn not provided)
- CloudWatch Log Group for control plane logs
- IAM Roles:
  - Cluster role
  - Node role
  - EBS CSI Driver role (if enabled)
  - ALB Controller role (if enabled)
- OIDC Provider for IRSA
- EKS Add-ons:
  - VPC CNI
  - kube-proxy
  - CoreDNS
  - EKS Pod Identity Agent
  - EBS CSI Driver

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| cluster_version | Kubernetes version for the EKS cluster | `string` | `"1.31"` | no |
| endpoint_private_access | Enable private API server endpoint | `bool` | `true` | no |
| endpoint_public_access | Enable public API server endpoint | `bool` | `true` | no |
| public_access_cidrs | List of CIDR blocks for public endpoint access | `list(string)` | `["0.0.0.0/0"]` | no |
| auto_mode_node_pools | List of node pools for EKS Auto Mode | `list(string)` | `["general-purpose"]` | no |
| kms_key_arn | ARN of KMS key for encryption (empty creates new) | `string` | `""` | no |
| kms_deletion_window_in_days | KMS key deletion window (7-30 days) | `number` | `30` | no |
| enabled_cluster_log_types | Control plane logging types to enable | `list(string)` | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` | no |
| log_retention_days | CloudWatch log retention in days | `number` | `7` | no |
| authentication_mode | Authentication mode (API, API_AND_CONFIG_MAP, CONFIG_MAP) | `string` | `"API_AND_CONFIG_MAP"` | no |
| bootstrap_cluster_creator_admin_permissions | Bootstrap cluster creator with admin permissions | `bool` | `true` | no |
| bootstrap_self_managed_addons | Bootstrap self-managed add-ons | `bool` | `false` | no |
| support_type | Support type (STANDARD, EXTENDED) | `string` | `"STANDARD"` | no |
| zonal_shift_enabled | Enable zonal shift for the cluster | `bool` | `false` | no |
| enable_vpc_cni_addon | Enable VPC CNI add-on | `bool` | `true` | no |
| enable_kube_proxy_addon | Enable kube-proxy add-on | `bool` | `true` | no |
| enable_coredns_addon | Enable CoreDNS add-on | `bool` | `true` | no |
| enable_pod_identity_addon | Enable EKS Pod Identity add-on | `bool` | `true` | no |
| enable_ebs_csi_driver_addon | Enable EBS CSI driver add-on | `bool` | `true` | no |
| enable_alb_controller | Enable AWS Load Balancer Controller IAM role | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID/name of the EKS cluster |
| cluster_arn | The ARN of the EKS cluster |
| cluster_endpoint | Endpoint for the EKS cluster API server |
| cluster_version | The Kubernetes version of the cluster |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data (sensitive) |
| oidc_provider_arn | ARN of the OIDC Provider for the EKS cluster |
| cluster_oidc_issuer_url | The URL of the OpenID Connect identity provider |
| cluster_iam_role_arn | ARN of the IAM role used by the EKS cluster |
| node_iam_role_arn | ARN of the IAM role used by EKS nodes |
| ebs_csi_driver_iam_role_arn | ARN of the IAM role used by EBS CSI driver |
| alb_controller_iam_role_arn | ARN of the IAM role used by AWS Load Balancer Controller |
| kms_key_arn | ARN of the KMS key used for cluster encryption |
| cloudwatch_log_group_name | Name of the CloudWatch log group for cluster logs |

## Notes

### EKS Auto Mode

This module uses EKS Auto Mode which automatically provisions and manages compute capacity. The `auto_mode_node_pools` variable accepts:
- `general-purpose`: For typical workloads
- `system`: For system workloads

### KMS Encryption

If `kms_key_arn` is empty, the module creates a new KMS key with automatic rotation enabled. Provide an existing KMS key ARN to use a shared key.

### Add-on Versions

Add-on versions default to `null`, which installs the latest compatible version. Specify explicit versions for production environments:

```hcl
vpc_cni_addon_version    = "v1.16.0-eksbuild.1"
kube_proxy_addon_version = "v1.28.2-eksbuild.2"
```

### IRSA (IAM Roles for Service Accounts)

The module creates an OIDC provider enabling IRSA. Use the `oidc_provider_arn` output to create additional IAM roles for Kubernetes service accounts.

### AWS Load Balancer Controller

The module creates the IAM role required for AWS Load Balancer Controller. Deploy the controller using Helm after cluster creation:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<alb-controller-iam-role-arn>
```

## Examples

See the following directories for complete examples:
- `nonprod/eks/dev/` - Development cluster configuration
- `nonprod/eks/test/` - Test cluster configuration
