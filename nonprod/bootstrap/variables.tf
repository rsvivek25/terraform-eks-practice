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
  default     = "nonprod"
}
