# EKS Network Module

This module creates private subnets for EKS in an existing VPC with an existing NAT Gateway.

## Features

- Creates EKS private subnets across multiple availability zones
- Creates a private route table with NAT Gateway route
- Associates subnets with the route table
- Adds EKS-required tags for subnet discovery and load balancer provisioning

## Usage

```hcl
module "eks_network" {
  source = "../../modules/eks-network"

  name_prefix      = "aws-blueprint-nonprod"
  vpc_id           = "vpc-xxxxxxxxx"
  nat_gateway_id   = "nat-xxxxxxxxx"
  cluster_name     = "aws-blueprint-nonprod-eks"
  
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  eks_subnet_cidrs   = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Environment = "nonprod"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name_prefix | Prefix for resource naming | string | yes |
| vpc_id | ID of the existing VPC | string | yes |
| nat_gateway_id | ID of the existing NAT Gateway | string | yes |
| availability_zones | List of AZs for EKS subnets | list(string) | yes |
| eks_subnet_cidrs | CIDR blocks for EKS subnets | list(string) | yes |
| cluster_name | Name of the EKS cluster | string | yes |
| tags | Additional resource tags | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| eks_subnet_ids | IDs of the EKS private subnets |
| eks_subnet_cidrs | CIDR blocks of the subnets |
| eks_subnet_availability_zones | AZs of the subnets |
| eks_route_table_id | ID of the private route table |
| nat_gateway_id | ID of the NAT Gateway |
| nat_gateway_public_ip | Public IP of the NAT Gateway |

## Subnet Tags

The module automatically adds these tags to subnets:

- `kubernetes.io/role/internal-elb = "1"` - For internal load balancers
- `kubernetes.io/cluster/<cluster-name> = "shared"` - For EKS discovery
