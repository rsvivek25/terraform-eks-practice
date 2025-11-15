# Using the EKS Add-on Module in Other Environments

This guide shows how to use the `eks-addon` module in different environments.

> **Note:** This module uses **EKS Pod Identity** instead of IRSA. Pod Identity is simpler and doesn't require OIDC provider configuration.

> **Note:** AWS Load Balancer Controller is pre-installed in EKS Auto Mode clusters and does not require additional IAM role configuration.

## Quick Start

The module has already been implemented in the **dev** environment. To use it in other environments (staging, prod, etc.), follow these steps:

### 1. Add the Module to Your Environment

In your environment's `main.tf` or create a new file `eks-addon.tf`:

```hcl
################################################################################
# EKS Add-on Module
################################################################################

module "eks_addon" {
  source = "../../../modules/eks-addon"

  cluster_name = var.cluster_name

  # Enable the add-ons you need
  enable_efs_csi_driver = true
  enable_external_dns   = true

  # Optional: Restrict External DNS to specific hosted zones
  # external_dns_route53_zone_arns = [
  #   "arn:aws:route53:::hostedzone/Z1234567890ABC"
  # ]

  tags = var.tags

  # Module depends on EKS cluster being created first
  depends_on = [module.eks]
}
```

### 2. Update Locals to Use Module Outputs

Add or update the `locals` block in your `main.tf`:

**Important:** When using Pod Identity, you don't need to specify `service_account_role_arn` in the add-on configuration. The Pod Identity associations automatically link the IAM roles to the service accounts.

```hcl
locals {
  # ... other locals ...

  # Merge user-provided add-ons with required add-ons
  # Note: With Pod Identity, IAM roles are associated automatically
  cluster_addons = merge(
    var.cluster_addons,
    {
      # Amazon EFS CSI Driver
      aws-efs-csi-driver = {
        most_recent = true
      }

      # External DNS
      external-dns = {
        most_recent = true
      }
    }
  )
}
```

### 3. Update EKS Module to Use Local Add-ons

In your EKS module configuration:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.8"

  # ... other configuration ...

  # Use local add-ons configuration
  addons = local.cluster_addons

  # ... rest of configuration ...
}
```

### 4. Add Outputs (Optional)

In your `outputs.tf`:

```hcl
################################################################################
# Add-on IAM Roles
################################################################################

output "efs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EFS CSI Driver"
  value       = module.eks_addon.efs_csi_driver_role_arn
}

output "external_dns_role_arn" {
  description = "ARN of the IAM role for External DNS"
  value       = module.eks_addon.external_dns_role_arn
}

output "cluster_addons" {
  description = "Map of enabled cluster add-ons"
  value       = local.cluster_addons
}
```

## Environment-Specific Configurations

### Development Environment
```hcl
module "eks_addon" {
  source = "../../../modules/eks-addon"

  cluster_name = "eks-nonprod-dev"

  enable_efs_csi_driver = true
  enable_external_dns   = true

  tags = var.tags

  depends_on = [module.eks]
}
```

### Staging Environment
```hcl
module "eks_addon" {
  source = "../../../modules/eks-addon"

  cluster_name = "eks-nonprod-staging"

  enable_efs_csi_driver = true
  enable_external_dns   = true

  # Restrict to staging domain
  external_dns_route53_zone_arns = [
    "arn:aws:route53:::hostedzone/ZSTAGING123456"
  ]

  tags = var.tags

  depends_on = [module.eks]
}
```

### Production Environment
```hcl
module "eks_addon" {
  source = "../../../modules/eks-addon"

  cluster_name = "eks-prod"

  enable_efs_csi_driver = true
  enable_external_dns   = true

  # Restrict to production domains only
  external_dns_route53_zone_arns = [
    "arn:aws:route53:::hostedzone/ZPROD123456",
    "arn:aws:route53:::hostedzone/ZPROD789012"
  ]

  tags = merge(
    var.tags,
    {
      Environment = "production"
      Compliance  = "required"
    }
  )
}
```

## Module Customization

### Enabling/Disabling Add-ons

Use the boolean flags to control which add-ons are created:

```hcl
# Only EFS CSI Driver
enable_efs_csi_driver = true
enable_external_dns   = false

# Only External DNS
enable_efs_csi_driver = false
enable_external_dns   = true

# Both add-ons
enable_efs_csi_driver = true
enable_external_dns   = true
```

### Route53 Zone Restrictions

For production environments, restrict External DNS to specific hosted zones:

```hcl
# All hosted zones (default - not recommended for production)
external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/*"]

# Specific zones only (recommended)
external_dns_route53_zone_arns = [
  "arn:aws:route53:::hostedzone/Z1D633PJN98FT9",
  "arn:aws:route53:::hostedzone/Z2FDTNDATAQYW2"
]
```

## Directory Structure

```
terraform-eks-practice/
├── modules/
│   └── eks-addon/                    # Reusable module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── nonprod/
│   ├── eks/
│   │   ├── dev/
│   │   │   ├── main.tf               # Uses module
│   │   │   └── ...
│   │   └── staging/                  # Can use same module
│   │       ├── main.tf
│   │       └── ...
└── prod/
    └── eks/
        └── prod/                      # Can use same module
            ├── main.tf
            ├── addon-iam-roles.tf
            └── ...
```

## Benefits of Using the Module

✅ **DRY Principle** - Define once, use everywhere
✅ **Consistency** - Same IAM roles across all environments
✅ **Easy Updates** - Update module once, affects all environments
✅ **Version Control** - Track changes to IAM policies in one place
✅ **Reduced Errors** - Less code duplication means fewer mistakes
✅ **Flexibility** - Enable/disable add-ons per environment

## Next Steps

1. Copy the module call to your environment's configuration
2. Adjust the `enable_*` flags based on your needs
3. Configure environment-specific settings (zone ARNs, tags, etc.)
4. Run `terraform plan` to verify the changes
5. Apply the configuration with `terraform apply`

## Troubleshooting

### Module Not Found Error

```
Error: Module not found: ../../../modules/eks-addon
```

**Solution:** Verify the relative path to the module from your environment directory. The path should be relative to where you're calling the module from.

### OIDC Provider Not Found

```
Error: no matching IAM OIDC Provider found
```

**Solution:** Ensure the EKS cluster has been created and the OIDC provider is enabled. The module depends on `module.eks`, so it should be created after the EKS cluster.

## Additional Resources

- [Module README](../../../modules/eks-addon/README.md)
- [Terraform Modules Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
