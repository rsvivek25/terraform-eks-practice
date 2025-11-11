################################################################################
# EKS Network Module
# Creates EKS subnets in existing VPC with existing NAT Gateway
################################################################################

################################################################################
# Data Sources - Existing VPC and NAT Gateway
################################################################################

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_nat_gateway" "existing" {
  id = var.nat_gateway_id
}

################################################################################
# EKS Private Subnets
################################################################################

resource "aws_subnet" "eks_private" {
  count             = length(var.eks_subnet_cidrs)
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = var.eks_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name                              = "${var.name_prefix}-eks-private-subnet-${var.availability_zones[count.index]}"
      Type                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

################################################################################
# Private Route Table for EKS Subnets
################################################################################

resource "aws_route_table" "eks_private" {
  vpc_id = data.aws_vpc.existing.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eks-private-rt"
      Type = "private"
    }
  )
}

# Route to NAT Gateway for internet access
resource "aws_route" "eks_private_nat" {
  route_table_id         = aws_route_table.eks_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.existing.id
}

# Associate subnets with route table
resource "aws_route_table_association" "eks_private" {
  count          = length(var.eks_subnet_cidrs)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}

################################################################################
# Security Group for EKS Cluster
################################################################################

resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.name_prefix}-eks-cluster-sg-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = data.aws_vpc.existing.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eks-cluster-sg"
    }
  )
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "eks_cluster_egress" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow all outbound traffic"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eks-cluster-egress"
    }
  )
}

# Allow all inbound traffic from VPC CIDR
resource "aws_vpc_security_group_ingress_rule" "eks_cluster_ingress_vpc" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow all inbound traffic from VPC CIDR"

  ip_protocol = "-1"
  cidr_ipv4   = var.vpc_cidr_block

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eks-cluster-ingress-vpc"
    }
  )
}
