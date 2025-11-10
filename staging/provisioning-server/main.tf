################################################################################
# Provisioning Server for Terraform Execution
# This EC2 instance will run all Terraform code for the account
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure these values after bootstrap
    # bucket         = "aws-blueprint-nonprod-terraform-state-<account-id>"
    # key            = "provisioning-server/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "aws-blueprint-nonprod-terraform-locks"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "ProvisioningServer"
      Account     = "staging"
    }
  }
}

################################################################################
# Data Sources
################################################################################

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# Security Group for Provisioning Server
################################################################################

resource "aws_security_group" "provisioning_server" {
  name_prefix = "${var.project_name}-${var.environment}-provisioning-server-"
  description = "Security group for Terraform provisioning server"
  vpc_id      = var.vpc_id

  # Egress - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Ingress - SSH from specified CIDR blocks
  dynamic "ingress" {
    for_each = var.ssh_allowed_cidr_blocks
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "SSH access from ${ingress.value}"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-provisioning-server-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# EC2 Instance - Provisioning Server
################################################################################

resource "aws_instance" "provisioning_server" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.provisioning_server.id]
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-${var.environment}-provisioning-server-root"
    }
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    terraform_version = var.terraform_version
    aws_region        = var.aws_region
    environment       = var.environment
    project_name      = var.project_name
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring = var.enable_detailed_monitoring

  tags = {
    Name        = "${var.project_name}-${var.environment}-provisioning-server"
    Description = "Terraform provisioning server for ${var.environment} account"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

################################################################################
# Elastic IP (Optional)
################################################################################

resource "aws_eip" "provisioning_server" {
  count    = var.allocate_elastic_ip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.provisioning_server.id

  tags = {
    Name = "${var.project_name}-${var.environment}-provisioning-server-eip"
  }
}

################################################################################
# CloudWatch Log Group for Server Logs
################################################################################

resource "aws_cloudwatch_log_group" "provisioning_server" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}-provisioning-server"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-${var.environment}-provisioning-server-logs"
  }
}
