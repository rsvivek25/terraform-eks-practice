################################################################################
# EFS CSI Driver Outputs
################################################################################

output "efs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EFS CSI Driver"
  value       = var.enable_efs_csi_driver ? aws_iam_role.efs_csi_driver[0].arn : null
}

output "efs_csi_driver_role_name" {
  description = "Name of the IAM role for EFS CSI Driver"
  value       = var.enable_efs_csi_driver ? aws_iam_role.efs_csi_driver[0].name : null
}

output "efs_csi_driver_pod_identity_association_id" {
  description = "ID of the EKS Pod Identity Association for EFS CSI Driver"
  value       = var.enable_efs_csi_driver ? aws_eks_pod_identity_association.efs_csi_driver[0].id : null
}

################################################################################
# External DNS Outputs
################################################################################

output "external_dns_role_arn" {
  description = "ARN of the IAM role for External DNS"
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}

output "external_dns_role_name" {
  description = "Name of the IAM role for External DNS"
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].name : null
}

output "external_dns_policy_arn" {
  description = "ARN of the IAM policy for External DNS"
  value       = var.enable_external_dns ? aws_iam_policy.external_dns[0].arn : null
}

output "external_dns_pod_identity_association_id" {
  description = "ID of the EKS Pod Identity Association for External DNS"
  value       = var.enable_external_dns ? aws_eks_pod_identity_association.external_dns[0].id : null
}
