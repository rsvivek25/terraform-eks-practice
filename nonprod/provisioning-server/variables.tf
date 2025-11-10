variable "aws_region" {
  description = "AWS region for the provisioning server"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "aws-blueprint"
}

variable "environment" {
  description = "Environment name (nonprod, staging, production)"
  type        = string
  default     = "nonprod"
}

variable "vpc_id" {
  description = "VPC ID where the provisioning server will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the provisioning server will be deployed (should be a private subnet)"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name from bootstrap (terraform-execution-instance-profile)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the provisioning server"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the provisioning server (defaults to latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 50
}

variable "ssh_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "allocate_elastic_ip" {
  description = "Whether to allocate an Elastic IP for the provisioning server"
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 30
}

variable "terraform_version" {
  description = "Terraform version to install on the provisioning server"
  type        = string
  default     = "1.10.0"
}
