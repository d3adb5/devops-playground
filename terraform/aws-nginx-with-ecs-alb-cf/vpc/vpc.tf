# tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "default" {
  count      = var.enabled ? 1 : 0
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "default" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.default[0].id
}

resource "aws_eip" "ngw" {
  count = var.enabled ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "default" {
  count         = var.enabled ? 1 : 0
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.ngw[0].id
}

resource "aws_subnet" "public" {
  for_each = var.enabled ? local.public_cidr_blocks : {}

  vpc_id            = aws_vpc.default[0].id
  cidr_block        = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each = var.enabled ? local.private_cidr_blocks : {}

  vpc_id            = aws_vpc.default[0].id
  cidr_block        = each.value
  availability_zone = each.key
}

# Public subnets will have a default route to the Internet Gateway (IGW).

resource "aws_route_table" "public" {
  count = var.enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default[0].id
  }
}

# Private subnets will have a default route to the NAT Gateway (NGW).

resource "aws_route_table" "private" {
  count = var.enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.default[0].id
  }
}

# Routing table associations!

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}
