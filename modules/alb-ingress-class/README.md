# ALB Ingress Class Module

This module creates an IngressClass and IngressClassParams for the AWS Load Balancer Controller in EKS Auto Mode.

## Features

- Creates IngressClassParams with configurable ALB scheme (internal/internet-facing)
- Creates IngressClass with ALB controller configuration
- Supports custom subnet selection
- Optional default IngressClass annotation
- Optional ALB tagging

## Usage

```hcl
module "alb_ingress_class" {
  source = "../../../modules/alb-ingress-class"

  ingress_class_name = "alb"
  alb_scheme         = "internal"
  subnet_ids         = var.private_subnet_ids
  is_default_class   = true
  
  alb_tags = {
    Environment = "nonprod"
    ManagedBy   = "Terraform"
  }

  depends_on = [module.eks]
}
```

## Requirements

- EKS cluster with Auto Mode enabled
- Kubernetes provider configured with cluster access

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ingress_class_name | Name of the IngressClass and IngressClassParams | `string` | `"alb"` | no |
| alb_scheme | ALB scheme: internal or internet-facing | `string` | `"internal"` | no |
| subnet_ids | List of subnet IDs where ALB will be deployed | `list(string)` | n/a | yes |
| is_default_class | Set this IngressClass as the default for the cluster | `bool` | `true` | no |
| alb_tags | Additional tags to apply to the ALB | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| ingress_class_name | Name of the created IngressClass |
| alb_scheme | ALB scheme (internal or internet-facing) |
| subnet_ids | Subnet IDs used for ALB deployment |

## Notes

- The `is_default_class` annotation makes this IngressClass the default. Ingress resources without a class will use this.
- Use `internal` scheme for private services within VPC
- Use `internet-facing` scheme for public-facing applications
- Subnet IDs should match the desired ALB placement (private for internal, public for internet-facing)
