# Bootstrap Infrastructure - NonProd Account

This directory contains the bootstrap infrastructure for the NonProd AWS account. This must be run **first** before any other Terraform configurations.

## Purpose

The bootstrap infrastructure creates:
- S3 bucket for Terraform state storage (with versioning and encryption)
- DynamoDB table for state locking
- KMS key for encryption
- IAM roles and instance profiles for Terraform execution

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed

## Usage

### Initial Bootstrap (Run Once)

```bash
# Navigate to the bootstrap directory
cd nonprod/bootstrap

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

### Important Notes

1. **State Storage**: This initial bootstrap run will store state **locally**. After creation, you can optionally migrate this state to the created S3 bucket.

2. **Idempotent**: This configuration is idempotent and can be run multiple times without issues.

3. **Backend Migration** (Optional): After bootstrapping, you can configure the backend to use the created S3 bucket:

```hcl
# Add this to main.tf after initial creation
terraform {
  backend "s3" {
    bucket         = "aws-blueprint-nonprod-terraform-state-<account-id>"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-blueprint-nonprod-terraform-locks"
    encrypt        = true
  }
}
```

Then run:
```bash
terraform init -migrate-state
```

## Outputs

After successful apply, note the following outputs:
- `s3_bucket_name`: Use this for backend configuration in other modules
- `dynamodb_table_name`: Use this for state locking
- `terraform_execution_instance_profile_name`: Use this for the provisioning server
- `backend_config`: Complete backend configuration for other workspaces

## Cleanup

⚠️ **Warning**: Only destroy bootstrap infrastructure when decommissioning the entire environment.

```bash
terraform destroy -var-file=terraform.tfvars
```
