variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-blueprint"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "nonprod"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "nat_gateway_id" {
  description = "ID of the existing NAT Gateway"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for EKS subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eks_subnet_cidrs" {
  description = "CIDR blocks for EKS private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
