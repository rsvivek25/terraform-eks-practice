################################################################################
# EKS Add-on IAM Roles Module
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
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
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
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
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
