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
