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
    bucket         = "eks-practice-nonprod-terraform-state-156041399540"
    key            = "eks-network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-practice-nonprod-terraform-locks"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:156041399540:key/52bec355-a23b-4a51-92cd-764534449809"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "EKS-Network"
      Account     = "nonprod"
    }
  }
}

################################################################################
# EKS Network Module
################################################################################

module "eks_network" {
  source = "../../modules/eks-network"

  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_id             = var.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  nat_gateway_id     = var.nat_gateway_id
  cluster_name       = "${var.project_name}-${var.environment}-eks"
  availability_zones = var.availability_zones
  eks_subnet_cidrs   = var.eks_subnet_cidrs

  tags = var.tags
}
