################################################################################
# Network Configuration - NonProd Account
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
    # key            = "network/terraform.tfstate"
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
      Purpose     = "Network"
      Account     = "nonprod"
    }
  }
}

################################################################################
# VPC Network Module
################################################################################

module "network" {
  source = "../../modules/network"

  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_dns_hostnames     = var.enable_dns_hostnames
  enable_dns_support       = var.enable_dns_support
  create_internet_gateway  = var.create_internet_gateway
  enable_nat_gateway       = var.enable_nat_gateway
  single_nat_gateway       = var.single_nat_gateway
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_traffic_type   = var.flow_logs_traffic_type
  flow_logs_retention_days = var.flow_logs_retention_days

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}
