# EKS Dev Cluster - NonProd Account

This directory contains the Terraform configuration for the **dev** EKS cluster in the NonProd AWS account.

## Purpose

The dev cluster is used for:
- Development and experimentation
- Testing new features and configurations
- Integration testing
- Developer workloads

## Prerequisites

1. **Bootstrap completed** - S3 backend and IAM roles must exist
2. **Network infrastructure** - VPC and subnets must be available
3. **Provisioning server** - Optional but recommended for consistency

## Configuration Steps

### 1. Update Backend Configuration

Edit `main.tf` and uncomment the backend configuration:

```hcl
backend "s3" {
  bucket         = "aws-blueprint-nonprod-terraform-state-<account-id>"
  key            = "eks/dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "aws-blueprint-nonprod-terraform-locks"
  encrypt        = true
}
```

### 2. Update terraform.tfvars

Edit `terraform.tfvars` and configure:
- `vpc_id`: Your VPC ID
- `subnet_ids`: List of private subnet IDs (3 AZs recommended)
- `cluster_endpoint_public_access_cidrs`: Restrict to your IP ranges

### 3. Create EKS Module (TODO)

The EKS module needs to be created in `modules/eks/`. Until then, this configuration includes a placeholder.

### 4. Deploy the Cluster

```bash
# Navigate to dev cluster directory
cd nonprod/eks/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

## Cluster Details

- **Name**: `aws-blueprint-nonprod-dev`
- **Version**: Kubernetes 1.31
- **Environment**: nonprod
- **Purpose**: Development and testing

## Features Enabled

- ✅ Secrets encryption (KMS envelope encryption)
- ✅ Control plane logging to CloudWatch
- ✅ Deletion protection
- ✅ ARC Zonal Shift for HA
- ✅ Public and private endpoint access

## Accessing the Cluster

After deployment:

```bash
# Update kubeconfig
aws eks update-kubeconfig --name aws-blueprint-nonprod-dev --region us-east-1

# Verify access
kubectl get nodes
kubectl get namespaces
```

## Differences from Test Cluster

The dev cluster configuration is similar to test but may have:
- Different resource quotas
- Less restrictive network policies
- Faster deployment cycles
- Experimental features enabled

## Cleanup

⚠️ **Warning**: Only destroy when decommissioning the dev environment.

```bash
terraform destroy -var-file=terraform.tfvars
```

## Next Steps

1. Update VPC and subnet IDs in `terraform.tfvars`
2. Create EKS module in `modules/eks/`
3. Update `main.tf` to use the EKS module
4. Deploy the cluster
5. Configure kubectl access
6. Deploy applications

## Related Resources

- Test cluster: `../test/`
- Network configuration: `../../network/`
- Bootstrap: `../../bootstrap/`
