# EKS Add-on IAM Roles Module

This module creates IAM roles and policies for common EKS add-ons using IRSA (IAM Roles for Service Accounts).

> **Note:** AWS Load Balancer Controller is pre-installed in EKS Auto Mode clusters and does not require additional IAM role configuration.

## Supported Add-ons

1. **Amazon EFS CSI Driver** - Dynamic provisioning of EFS volumes
2. **External DNS** - Automatic DNS record management in Route53

## Features

- ✅ IRSA (IAM Roles for Service Accounts) integration
- ✅ Conditional creation - enable only the add-ons you need
- ✅ Follows AWS best practices for IAM permissions
- ✅ Reusable across multiple environments
- ✅ Properly scoped Route53 permissions for External DNS

## Usage

### Basic Example

```hcl
module "eks_addon_iam_roles" {
  source = "../../modules/eks-addon-iam-roles"

  cluster_name       = "my-eks-cluster"
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  # Enable the add-ons you need
  enable_efs_csi_driver = true
  enable_external_dns   = true

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with External DNS Zone Restrictions

```hcl
module "eks_addon_iam_roles" {
  source = "../../modules/eks-addon-iam-roles"

  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  # Enable both add-ons
  enable_efs_csi_driver = true
  enable_external_dns   = true

  # Restrict External DNS to specific hosted zones
  external_dns_route53_zone_arns = [
    "arn:aws:route53:::hostedzone/Z1234567890ABC",
    "arn:aws:route53:::hostedzone/Z0987654321XYZ"
  ]

  tags = var.tags
}
```

### Using with EKS Add-ons

```hcl
locals {
  cluster_addons = {
    # EFS CSI Driver
    aws-efs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.eks_addon_iam_roles.efs_csi_driver_role_arn
    }

    # External DNS
    external-dns = {
      most_recent              = true
      service_account_role_arn = module.eks_addon_iam_roles.external_dns_role_arn
    }
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  # ... other configuration ...
  
  addons = local.cluster_addons
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| oidc_provider_arn | ARN of the OIDC provider for the EKS cluster | `string` | n/a | yes |
| oidc_provider | OIDC provider URL without https:// prefix | `string` | n/a | yes |
| enable_efs_csi_driver | Enable IAM role for EFS CSI Driver add-on | `bool` | `false` | no |
| enable_external_dns | Enable IAM role for External DNS add-on | `bool` | `false` | no |
| external_dns_route53_zone_arns | List of Route53 hosted zone ARNs that External DNS can manage | `list(string)` | `["arn:aws:route53:::hostedzone/*"]` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| efs_csi_driver_role_arn | ARN of the IAM role for EFS CSI Driver |
| efs_csi_driver_role_name | Name of the IAM role for EFS CSI Driver |
| external_dns_role_arn | ARN of the IAM role for External DNS |
| external_dns_role_name | Name of the IAM role for External DNS |
| external_dns_policy_arn | ARN of the IAM policy for External DNS |

## IAM Permissions

### EFS CSI Driver
- Uses AWS managed policy: `AmazonEFSCSIDriverPolicy`
- Allows EFS file system operations

### External DNS
- `route53:ChangeResourceRecordSets` - Create/update/delete DNS records
- `route53:ListHostedZones` - List available hosted zones
- `route53:ListResourceRecordSets` - List existing DNS records
- `route53:ListTagsForResource` - List tags on hosted zones
- Complete set of permissions for managing ALB/NLB
- EC2, ELB, WAF, Shield, ACM, Cognito permissions
- Security group and tag management

## Service Account Configuration

Each add-on expects a specific service account in the `kube-system` namespace:

- **EFS CSI Driver**: `efs-csi-controller-sa`
- **External DNS**: `external-dns`

> **Note:** AWS Load Balancer Controller is pre-installed in EKS Auto Mode and manages its own service account automatically.

## Security Considerations

1. **External DNS**: By default, External DNS can manage all Route53 hosted zones. Use `external_dns_route53_zone_arns` to restrict access to specific zones.

2. **Least Privilege**: Enable only the add-ons you actually need by setting the corresponding `enable_*` flags.

3. **IRSA**: All roles use IRSA which provides temporary credentials and eliminates the need to store AWS credentials in pods.

## License

Apache 2.0 Licensed. See LICENSE for full details.
