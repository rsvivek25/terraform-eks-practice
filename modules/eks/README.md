# EKS Auto Mode Module

This module wraps the official [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module v21.8.0 with EKS Auto Mode configuration.

## Features

- **EKS Auto Mode**: Fully managed compute with automatic node provisioning
- **Security**: KMS encryption, private endpoints, security group management
- **Logging**: Configurable CloudWatch control plane logging
- **High Availability**: Zonal shift and multi-AZ deployment support
- **Access Control**: Flexible authentication modes with IAM integration

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"
  
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-xxxxx", "subnet-yyyyy", "subnet-zzzzz"]
  
  auto_mode_node_pools = ["general-purpose"]
  
  tags = {
    Environment = "dev"
  }
}
```

## Auto Mode

This module enables EKS Auto Mode which automatically:
- Provisions and manages compute capacity
- Handles node scaling based on workload requirements
- Manages node lifecycle and updates
- Configures networking and security

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0
- Private subnets with NAT Gateway for internet access
- Existing VPC and security groups

## Inputs

See [variables.tf](./variables.tf) for full input documentation.

## Outputs

See [outputs.tf](./outputs.tf) for available outputs.
