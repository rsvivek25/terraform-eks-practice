variable "aws_region" {
  description = "AWS region for the bootstrap infrastructure"
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
  default     = "production"
}

variable "trusted_account_ids" {
  description = "List of AWS account IDs allowed to assume the Terraform execution role"
  type        = list(string)
  default     = []
}

variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
  default     = "terraform-bootstrap-external-id"
  sensitive   = true
}
