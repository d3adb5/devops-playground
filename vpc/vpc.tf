resource "aws_vpc" "default" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_nat_gateway" "default" {
  subnet_id = aws_subnet.public[0].id
}

resource "aws_subnet" "public" {
  for_each = local.public_cidr_blocks

  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each = local.private_cidr_blocks

  vpc_id            = aws_vpc.default.id
  cidr_block        = each.value
  availability_zone = each.key
}

# Public subnets will have a default route to the Internet Gateway (IGW).

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

# Private subnets will have a default route to the NAT Gateway (NGW).

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.default.id
  }
}

# Routing table associations!

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
