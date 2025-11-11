# Provisioning Server Configuration - NonProd

project_name = "aws-blueprint"
environment  = "nonprod"
aws_region   = "us-east-1"

# VPC and Subnet Configuration
# Replace with your actual VPC and Subnet IDs
vpc_id    = "vpc-xxxxxxxxxxxxxxxxx"
subnet_id = "subnet-xxxxxxxxxxxxxxxxx"

# IAM Instance Profile from Bootstrap
# Get this from bootstrap outputs: terraform_execution_instance_profile_name
instance_profile_name = "aws-blueprint-nonprod-terraform-execution-profile"

# Instance Configuration
instance_type  = "t3.medium"
root_volume_size = 50

# SSH Access (Update with your CIDR blocks)
ssh_allowed_cidr_blocks = [
  # "10.0.0.0/8",  # Internal network
  # "203.0.113.0/24",  # Office IP range
]

# Elastic IP
allocate_elastic_ip = false

# Monitoring
enable_detailed_monitoring = true
log_retention_days        = 30

# Terraform Version
terraform_version = "1.10.0"
