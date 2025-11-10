# Cluster Outputs
output "cluster_id" {
  description = "The ID/name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "The platform version of the EKS cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

# Security Outputs
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# OIDC Provider Outputs
output "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

# IAM Role Outputs
output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_iam_role_name" {
  description = "Name of the IAM role used by the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by EKS nodes"
  value       = module.eks.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "Name of the IAM role used by EKS nodes"
  value       = module.eks.node_iam_role_name
}

output "ebs_csi_driver_iam_role_arn" {
  description = "ARN of the IAM role used by EBS CSI driver"
  value       = module.eks.ebs_csi_driver_iam_role_arn
}

output "alb_controller_iam_role_arn" {
  description = "ARN of the IAM role used by AWS Load Balancer Controller"
  value       = module.eks.alb_controller_iam_role_arn
}

# Encryption Outputs
output "kms_key_arn" {
  description = "ARN of the KMS key used for cluster encryption"
  value       = module.eks.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for cluster encryption"
  value       = module.eks.kms_key_id
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for cluster logs"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for cluster logs"
  value       = module.eks.cloudwatch_log_group_arn
}

output "vpc_id" {
  description = "VPC ID where cluster is deployed"
  value       = var.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs used by the cluster"
  value       = var.subnet_ids
}
