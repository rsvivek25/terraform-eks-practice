# Cluster Outputs
output "cluster_id" {
  description = "The ID/name of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "The platform version of the EKS cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

# Security Outputs
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# OIDC Provider Outputs
output "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect identity provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for the EKS cluster"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

# IAM Role Outputs
output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "cluster_iam_role_name" {
  description = "Name of the IAM role used by the EKS cluster"
  value       = aws_iam_role.cluster.name
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by EKS nodes"
  value       = aws_iam_role.node.arn
}

output "node_iam_role_name" {
  description = "Name of the IAM role used by EKS nodes"
  value       = aws_iam_role.node.name
}

output "ebs_csi_driver_iam_role_arn" {
  description = "ARN of the IAM role used by EBS CSI driver"
  value       = var.enable_ebs_csi_driver_addon && var.ebs_csi_driver_service_account_role_arn == "" ? aws_iam_role.ebs_csi_driver[0].arn : var.ebs_csi_driver_service_account_role_arn
}

output "alb_controller_iam_role_arn" {
  description = "ARN of the IAM role used by AWS Load Balancer Controller"
  value       = var.enable_alb_controller ? aws_iam_role.alb_controller[0].arn : ""
}

# Encryption Outputs
output "kms_key_arn" {
  description = "ARN of the KMS key used for cluster encryption"
  value       = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for cluster encryption"
  value       = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.eks[0].id
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for cluster logs"
  value       = aws_cloudwatch_log_group.eks.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for cluster logs"
  value       = aws_cloudwatch_log_group.eks.arn
}

# Add-on Outputs
output "vpc_cni_addon_version" {
  description = "Version of the VPC CNI add-on"
  value       = var.enable_vpc_cni_addon ? aws_eks_addon.vpc_cni[0].addon_version : null
}

output "kube_proxy_addon_version" {
  description = "Version of the kube-proxy add-on"
  value       = var.enable_kube_proxy_addon ? aws_eks_addon.kube_proxy[0].addon_version : null
}

output "coredns_addon_version" {
  description = "Version of the CoreDNS add-on"
  value       = var.enable_coredns_addon ? aws_eks_addon.coredns[0].addon_version : null
}

output "pod_identity_addon_version" {
  description = "Version of the EKS Pod Identity add-on"
  value       = var.enable_pod_identity_addon ? aws_eks_addon.pod_identity[0].addon_version : null
}

output "ebs_csi_driver_addon_version" {
  description = "Version of the EBS CSI driver add-on"
  value       = var.enable_ebs_csi_driver_addon ? aws_eks_addon.ebs_csi_driver[0].addon_version : null
}
