################################################################################
# Cluster Outputs
################################################################################

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "The status of the EKS cluster"
  value       = module.eks.cluster_status
}

################################################################################
# Certificate Authority
################################################################################

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

################################################################################
# OIDC Provider
################################################################################

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

################################################################################
# Security
################################################################################

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

################################################################################
# KMS
################################################################################

output "kms_key_id" {
  description = "KMS key ID used for cluster encryption"
  value       = module.eks.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for cluster encryption"
  value       = module.eks.kms_key_arn
}

################################################################################
# Access Configuration
################################################################################

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "access_entries" {
  description = "Map of access entries created and their attributes"
  value       = module.eks.access_entries
}
