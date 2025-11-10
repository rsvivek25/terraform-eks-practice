# Provisioning Server - NonProd Account

This directory contains the Terraform configuration for the EC2 provisioning server that will execute all Terraform code for the NonProd account.

## Purpose

The provisioning server is a dedicated EC2 instance with:
- Pre-installed Terraform, AWS CLI, kubectl, Helm, and Docker
- IAM instance profile with necessary permissions to manage AWS resources
- CloudWatch agent for log collection
- Secure access via SSH (configurable CIDR blocks)

## Prerequisites

1. **Bootstrap must be completed first** - Run the bootstrap configuration to create the S3 backend and IAM roles
2. AWS CLI configured with appropriate credentials
3. VPC and subnet must exist

## Configuration Steps

### 1. Update Backend Configuration

After bootstrap is complete, uncomment and update the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "aws-blueprint-nonprod-terraform-state-<account-id>"
  key            = "provisioning-server/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "aws-blueprint-nonprod-terraform-locks"
  encrypt        = true
}
```

### 2. Update terraform.tfvars

Edit `terraform.tfvars` to configure:
- `vpc_id`: Your VPC ID
- `subnet_id`: Subnet where the server will be deployed (recommend private subnet)
- `instance_profile_name`: From bootstrap outputs
- `ssh_allowed_cidr_blocks`: CIDR blocks allowed for SSH access

### 3. Deploy the Provisioning Server

```bash
# Navigate to the provisioning-server directory
cd nonprod/provisioning-server

# Initialize Terraform with backend
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

## Connecting to the Server

### Via SSM Session Manager (Recommended)

```bash
aws ssm start-session --target <instance-id>
```

### Via SSH (if configured)

```bash
ssh -i /path/to/key.pem ec2-user@<instance-ip>
```

## Using the Provisioning Server

Once connected to the server:

1. **Navigate to workspace**:
   ```bash
   cd ~/terraform-workspace
   ```

2. **Clone your infrastructure repository**:
   ```bash
   git clone <your-repo-url>
   ```

3. **Run Terraform commands**:
   ```bash
   cd <repo-directory>/nonprod/<resource-type>
   terraform init
   terraform plan
   terraform apply
   ```

## Installed Tools

- **Terraform**: Version specified in variables (default: 1.10.0)
- **AWS CLI**: Latest version
- **kubectl**: Latest stable version
- **Helm**: Latest version
- **Docker**: Latest version
- **Git, jq, vim, htop**: Standard utilities

## Monitoring

Logs are sent to CloudWatch Logs:
- Log Group: `/aws/ec2/aws-blueprint-nonprod-provisioning-server`
- Streams: messages, secure, terraform

View logs:
```bash
aws logs tail /aws/ec2/aws-blueprint-nonprod-provisioning-server --follow
```

## Security Considerations

1. **Private Subnet**: Deploy in a private subnet for enhanced security
2. **SSH Access**: Restrict SSH to specific CIDR blocks or use SSM Session Manager
3. **IAM Permissions**: The instance has AdministratorAccess - use carefully
4. **Encryption**: Root volume is encrypted by default
5. **IMDSv2**: Instance metadata service uses IMDSv2 (required)

## Cleanup

⚠️ **Warning**: Only destroy when decommissioning the account.

```bash
terraform destroy -var-file=terraform.tfvars
```

## Troubleshooting

### Check User Data Execution
```bash
# On the instance
cat /var/log/cloud-init-output.log
cat /tmp/user-data-complete.txt
```

### Verify Terraform Installation
```bash
terraform version
aws --version
kubectl version --client
helm version
```

### Check IAM Role
```bash
aws sts get-caller-identity
```
