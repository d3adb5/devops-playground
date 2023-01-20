output "vpc_id" {
  value = var.enabled ? aws_vpc.default[0].id : data.aws_vpc.default[0].id
}

output "public_subnets" {
  value = var.enabled ? values(aws_subnet.public).*.id : data.aws_subnet.public.*.id
}

output "private_subnets" {
  value = var.enabled ? values(aws_subnet.private).*.id : data.aws_subnet.private.*.id
}

# Data sources for when resources aren't being created.

data "aws_vpc" "default" {
  count      = var.enabled ? 0 : 1
  cidr_block = var.cidr_block
}

data "aws_subnet" "public" {
  for_each = var.enabled ? {} : local.public_cidr_blocks
  vpc_id   = data.aws_vpc.default[0].id
}

data "aws_subnet" "private" {
  for_each = var.enabled ? {} : local.private_cidr_blocks
  vpc_id   = data.aws_vpc.default[0].id
}
