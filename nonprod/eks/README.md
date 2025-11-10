# EKS Clusters - NonProd Account

This directory contains Terraform configurations for all EKS clusters in the NonProd AWS account.

## Directory Structure

```
nonprod/eks/
├── dev/                    # Development cluster
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
└── test/                   # Test/QA cluster
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── README.md
```

## Available Clusters

### Dev Cluster (`dev/`)
- **Name**: `aws-blueprint-nonprod-dev`
- **Purpose**: Development and experimentation
- **State File**: `eks/dev/terraform.tfstate`
- **Documentation**: See [dev/README.md](dev/README.md)

### Test Cluster (`test/`)
- **Name**: `aws-blueprint-nonprod-test`
- **Purpose**: QA and integration testing
- **State File**: `eks/test/terraform.tfstate`
- **Documentation**: See [test/README.md](test/README.md)

## Deployment Order

1. **Bootstrap** (if not already done)
   ```bash
   cd ../../bootstrap
   terraform apply
   ```

2. **Network** (if not already done)
   ```bash
   cd ../../network
   terraform apply
   ```

3. **Deploy Clusters**
   ```bash
   # Deploy dev cluster
   cd ../eks/dev
   terraform init
   terraform apply -var-file=terraform.tfvars

   # Deploy test cluster
   cd ../test
   terraform init
   terraform apply -var-file=terraform.tfvars
   ```

## Configuration

Each cluster has its own:
- **Independent state file** - No shared state between clusters
- **Separate tfvars** - Environment-specific configuration
- **Isolated resources** - Complete separation for safety

## Key Differences Between Clusters

| Feature | Dev | Test |
|---------|-----|------|
| **Purpose** | Development | QA/Testing |
| **Stability** | Experimental features allowed | Production-like |
| **Access** | Developer teams | QA teams |
| **Resources** | Flexible sizing | Production-like sizing |
| **Network Policies** | Less restrictive | More restrictive |
| **Monitoring** | Basic | Comprehensive |

## State Management

Each cluster maintains its own state file in S3:

- **Dev**: `s3://...state.../eks/dev/terraform.tfstate`
- **Test**: `s3://...state.../eks/test/terraform.tfstate`

This ensures:
- ✅ Independent deployments
- ✅ No accidental cross-cluster changes
- ✅ Separate state locking
- ✅ Clear ownership and responsibility

## Adding New Clusters

To add another cluster (e.g., `perf` for performance testing):

1. **Create directory**:
   ```bash
   mkdir perf
   ```

2. **Copy files from dev or test**:
   ```bash
   cp -r dev/* perf/
   ```

3. **Update configuration**:
   - Change `cluster_name` to `aws-blueprint-nonprod-perf`
   - Update backend key to `eks/perf/terraform.tfstate`
   - Modify tags: `Cluster = "perf"`

4. **Deploy**:
   ```bash
   cd perf
   terraform init
   terraform apply -var-file=terraform.tfvars
   ```

## Prerequisites

Before deploying any EKS cluster:

1. ✅ Bootstrap infrastructure exists
2. ✅ VPC and subnets are created
3. ✅ You have the VPC ID and subnet IDs
4. ✅ Backend configuration is updated in each cluster's `main.tf`

## Accessing Clusters

After deployment, update your kubeconfig:

```bash
# Dev cluster
aws eks update-kubeconfig --name aws-blueprint-nonprod-dev --region us-east-1

# Test cluster
aws eks update-kubeconfig --name aws-blueprint-nonprod-test --region us-east-1

# List available contexts
kubectl config get-contexts

# Switch between clusters
kubectl config use-context arn:aws:eks:us-east-1:ACCOUNT:cluster/aws-blueprint-nonprod-dev
kubectl config use-context arn:aws:eks:us-east-1:ACCOUNT:cluster/aws-blueprint-nonprod-test
```

## Cost Optimization

Tips for managing costs across multiple clusters:

1. **Right-size nodes** - Use appropriate instance types
2. **Auto-scaling** - Configure cluster autoscaler
3. **Spot instances** - Use for non-critical workloads
4. **Delete unused** - Remove clusters not in use
5. **Monitoring** - Track costs per cluster

## Cleanup

To destroy a cluster:

```bash
cd dev  # or test
terraform destroy -var-file=terraform.tfvars
```

⚠️ **Warning**: This will permanently delete the cluster and all its resources.

## Next Steps

1. Update `terraform.tfvars` in dev/ and test/ with your VPC and subnet IDs
2. Create EKS module in `modules/eks/`
3. Update each cluster's `main.tf` to use the EKS module
4. Deploy clusters following the deployment order above
5. Configure kubectl access
6. Deploy your applications

## Support

- Dev cluster documentation: [dev/README.md](dev/README.md)
- Test cluster documentation: [test/README.md](test/README.md)
- Network configuration: `../network/`
- Bootstrap: `../bootstrap/`
- Main blueprint README: `../../../README.md`
