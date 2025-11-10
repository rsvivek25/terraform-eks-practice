output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = aws_kms_key.terraform_state.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_execution_role_arn" {
  description = "ARN of the IAM role for Terraform execution"
  value       = aws_iam_role.terraform_execution.arn
}

output "terraform_execution_role_name" {
  description = "Name of the IAM role for Terraform execution"
  value       = aws_iam_role.terraform_execution.name
}

output "terraform_execution_instance_profile_arn" {
  description = "ARN of the instance profile for Terraform execution"
  value       = aws_iam_instance_profile.terraform_execution.arn
}

output "terraform_execution_instance_profile_name" {
  description = "Name of the instance profile for Terraform execution"
  value       = aws_iam_instance_profile.terraform_execution.name
}

output "backend_config" {
  description = "Backend configuration for other Terraform workspaces"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
    kms_key_id     = aws_kms_key.terraform_state.arn
  }
}
