################################################################################
# EKS Add-on IAM Roles Module
# Uses EKS Pod Identity for service account authentication
################################################################################

################################################################################
# IAM Role for EFS CSI Driver
################################################################################

resource "aws_iam_role" "efs_csi_driver" {
  count = var.enable_efs_csi_driver ? 1 : 0

  name = "${var.cluster_name}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-efs-csi-driver-role"
    }
  )
}

# Attach AWS managed policy for EFS CSI Driver
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count = var.enable_efs_csi_driver ? 1 : 0

  role       = aws_iam_role.efs_csi_driver[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

################################################################################
# IAM Role for External DNS
################################################################################

# IAM policy for External DNS
resource "aws_iam_policy" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name        = "${var.cluster_name}-external-dns-policy"
  description = "Policy for External DNS to manage Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = var.external_dns_route53_zone_arns
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-external-dns-policy"
    }
  )
}

# IAM role for External DNS
resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name = "${var.cluster_name}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-external-dns-role"
    }
  )
}

# Attach custom policy to External DNS role
resource "aws_iam_role_policy_attachment" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns[0].arn
}

################################################################################
# EKS Add-ons
################################################################################

# Data source for EFS CSI Driver latest version
data "aws_eks_addon_version" "efs_csi_driver" {
  count = var.enable_efs_csi_driver ? 1 : 0

  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

# EFS CSI Driver Add-on
resource "aws_eks_addon" "efs_csi_driver" {
  count = var.enable_efs_csi_driver ? 1 : 0

  cluster_name  = var.cluster_name
  addon_name    = "aws-efs-csi-driver"
  addon_version = data.aws_eks_addon_version.efs_csi_driver[0].version

  # Pod Identity configuration - addon will create the association automatically
  pod_identity_association {
    role_arn        = aws_iam_role.efs_csi_driver[0].arn
    service_account = "efs-csi-controller-sa"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-efs-csi-driver"
    }
  )
}

# Data source for External DNS latest version
data "aws_eks_addon_version" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  addon_name         = "external-dns"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

# External DNS Add-on
resource "aws_eks_addon" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  cluster_name  = var.cluster_name
  addon_name    = "external-dns"
  addon_version = data.aws_eks_addon_version.external_dns[0].version

  # Pod Identity configuration - addon will create the association automatically
  pod_identity_association {
    role_arn        = aws_iam_role.external_dns[0].arn
    service_account = "external-dns"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-external-dns"
    }
  )
}
