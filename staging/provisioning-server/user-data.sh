#!/bin/bash
# User data script for Terraform provisioning server

set -e

# Update system packages
dnf update -y

# Install required packages
dnf install -y \
    git \
    unzip \
    jq \
    wget \
    vim \
    htop \
    aws-cli \
    docker

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install Terraform
TERRAFORM_VERSION="${terraform_version}"
cd /tmp
wget "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm -f "terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Configure AWS CLI
mkdir -p /home/ec2-user/.aws
cat > /home/ec2-user/.aws/config <<EOF
[default]
region = ${aws_region}
output = json
EOF
chown -R ec2-user:ec2-user /home/ec2-user/.aws

# Create workspace directory
mkdir -p /home/ec2-user/terraform-workspace
chown -R ec2-user:ec2-user /home/ec2-user/terraform-workspace

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
rm -f ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-provisioning-server",
            "log_stream_name": "{instance_id}/messages"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-provisioning-server",
            "log_stream_name": "{instance_id}/secure"
          },
          {
            "file_path": "/home/ec2-user/terraform-workspace/terraform.log",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-provisioning-server",
            "log_stream_name": "{instance_id}/terraform"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Create helpful aliases and environment variables
cat >> /home/ec2-user/.bashrc <<EOF

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

# Environment variables
export TF_LOG_PATH=/home/ec2-user/terraform-workspace/terraform.log
export AWS_REGION=${aws_region}
export ENVIRONMENT=${environment}
export PROJECT_NAME=${project_name}

# Helpful message
echo "========================================="
echo "Terraform Provisioning Server"
echo "Environment: ${environment}"
echo "Region: ${aws_region}"
echo "========================================="
echo "Installed tools:"
echo "  - Terraform $${TERRAFORM_VERSION}"
echo "  - AWS CLI $(aws --version | cut -d' ' -f1)"
echo "  - kubectl (latest)"
echo "  - Helm (latest)"
echo "  - Docker $(docker --version | cut -d' ' -f3)"
echo "========================================="
EOF

# Create a welcome message
cat > /etc/motd <<EOF
========================================
 Terraform Provisioning Server
 Environment: ${environment}
 Project: ${project_name}
========================================
EOF

# Signal completion
echo "User data script completed successfully" > /tmp/user-data-complete.txt
