# EKS Test Cluster - NonProd Account

This directory contains the Terraform configuration for the **test** EKS cluster in the NonProd AWS account.

## Purpose

The test cluster is used for:
- Quality assurance testing
- Integration testing
- Pre-production validation
- Performance testing
- User acceptance testing (UAT)

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
  key            = "eks/test/terraform.tfstate"
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
# Navigate to test cluster directory
cd nonprod/eks/test

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

## Cluster Details

- **Name**: `aws-blueprint-nonprod-test`
- **Version**: Kubernetes 1.31
- **Environment**: nonprod
- **Purpose**: QA and integration testing

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
aws eks update-kubeconfig --name aws-blueprint-nonprod-test --region us-east-1

# Verify access
kubectl get nodes
kubectl get namespaces
```

## Differences from Dev Cluster

The test cluster is typically:
- More stable (fewer experimental features)
- Production-like configurations
- Stricter resource quotas
- Network policies enforced
- More comprehensive monitoring

## Managing Multiple Clusters

Both dev and test clusters can coexist:

```bash
# Switch between clusters
kubectl config get-contexts
kubectl config use-context arn:aws:eks:us-east-1:ACCOUNT_ID:cluster/aws-blueprint-nonprod-dev
kubectl config use-context arn:aws:eks:us-east-1:ACCOUNT_ID:cluster/aws-blueprint-nonprod-test
```

## Cleanup

⚠️ **Warning**: Only destroy when decommissioning the test environment.

```bash
terraform destroy -var-file=terraform.tfvars
```

## Next Steps

1. Update VPC and subnet IDs in `terraform.tfvars`
2. Create EKS module in `modules/eks/`
3. Update `main.tf` to use the EKS module
4. Deploy the cluster
5. Configure kubectl access
6. Deploy test applications

## Related Resources

- Dev cluster: `../dev/`
- Network configuration: `../../network/`
- Bootstrap: `../../bootstrap/`
