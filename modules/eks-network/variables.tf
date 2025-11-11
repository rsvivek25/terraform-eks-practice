variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
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
}

variable "eks_subnet_cidrs" {
  description = "CIDR blocks for EKS private subnets (one per AZ)"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster (for tagging)"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
