locals {
  public_subnets  = { for name, s in var.subnets : name => s if s.tier == "public" }
  private_subnets = { for name, s in var.subnets : name => s if s.tier == "private" }

  cluster_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  is_regional = var.nat_gateway_mode == "regional"

  # AZs that host a zonal NAT Gateway (where a public subnet exists). "per_az"
  # places one NAT per such AZ; "single" collapses to the first AZ. Regional mode
  # uses no zonal NATs (handled separately).
  public_azs = distinct([for s in local.public_subnets : s.az])
  nat_azs    = local.is_regional ? [] : (var.nat_gateway_mode == "single" ? [local.public_azs[0]] : local.public_azs)

  # az -> "01"/"02" suffix for NAT and EIP naming.
  nat_suffix = { for idx, az in local.nat_azs : az => format("%02d", idx + 1) }

  # az -> one public subnet name in that AZ (NAT placement). Assumes a single
  # public subnet per AZ.
  public_subnet_name_by_az = { for name, s in local.public_subnets : s.az => name }

  # private subnet name -> "01"/"02" suffix for private route table naming.
  private_rt_suffix = { for idx, name in keys(local.private_subnets) : name => format("%02d", idx + 1) }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.name_prefix}-vpc-01"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.cluster_tags, {
    Name                     = each.key
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.cluster_tags, {
    Name                              = each.key
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.name_prefix}-igw-01"
    Environment = var.environment
  }
}

# Zonal NAT Gateways: one per AZ ("per_az") or a single one ("single"). Not
# created in "regional" mode (nat_azs is empty), which uses aws_nat_gateway.regional.
resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)

  domain = "vpc"

  tags = {
    Name        = "${var.name_prefix}-eip-nat-${local.nat_suffix[each.key]}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[local.public_subnet_name_by_az[each.key]].id

  tags = {
    Name        = "${var.name_prefix}-nat-${local.nat_suffix[each.key]}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

# Regional NAT Gateway (auto mode): a single VPC-level NAT that automatically
# expands/contracts across AZs based on workload presence. No public subnet or
# EIP management required; AWS handles AZ coverage and IP allocation.
resource "aws_nat_gateway" "regional" {
  count = local.is_regional ? 1 : 0

  vpc_id            = aws_vpc.this.id
  availability_mode = "regional"

  tags = {
    Name        = "${var.name_prefix}-nat-rgnl-01"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

locals {
  # When route_tables is provided, the caller defines route tables/associations
  # explicitly (visible in their main.tf) and the auto-generated ones are skipped.
  use_explicit_route_tables = length(var.route_tables) > 0

  # The single NAT Gateway id used by explicit "nat" route tables (regional or
  # single mode). null when there is no NAT (e.g. egress "none" only).
  nat_id = local.is_regional ? aws_nat_gateway.regional[0].id : (
    length(local.nat_azs) > 0 ? aws_nat_gateway.this[local.nat_azs[0]].id : null
  )

  # subnet name -> id, across both tiers, for explicit associations.
  subnet_id_by_name = merge(
    { for name, s in aws_subnet.public : name => s.id },
    { for name, s in aws_subnet.private : name => s.id },
  )
}

# ── Auto-generated route tables (used when var.route_tables is empty) ──────────
resource "aws_route_table" "public" {
  count = local.use_explicit_route_tables ? 0 : 1

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.name_prefix}-rt-pub-01"
    Environment = var.environment
  }
}

# One private route table per private subnet, routing egress to the appropriate
# NAT Gateway: the regional NAT, the single NAT, or the NAT in the same AZ.
resource "aws_route_table" "private" {
  for_each = local.use_explicit_route_tables ? {} : local.private_subnets

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = local.is_regional ? aws_nat_gateway.regional[0].id : (
      var.nat_gateway_mode == "single" ? aws_nat_gateway.this[local.nat_azs[0]].id : aws_nat_gateway.this[each.value.az].id
    )
  }

  tags = {
    Name        = "${var.name_prefix}-rt-prv-${local.private_rt_suffix[each.key]}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.use_explicit_route_tables ? {} : local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  for_each = local.use_explicit_route_tables ? {} : local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# ── Explicit route tables (used when the caller passes var.route_tables) ───────
# Each route's destination CIDR and target are defined by the caller; the module
# only resolves the symbolic target ("igw"/"nat") to the gateway it manages.
resource "aws_route_table" "explicit" {
  for_each = var.route_tables

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block     = route.value.destination_cidr_block
      gateway_id     = route.value.target == "igw" ? aws_internet_gateway.this.id : null
      nat_gateway_id = route.value.target == "nat" ? local.nat_id : null
    }
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

resource "aws_route_table_association" "explicit" {
  for_each = var.route_table_associations

  subnet_id      = local.subnet_id_by_name[each.key]
  route_table_id = aws_route_table.explicit[each.value].id
}
