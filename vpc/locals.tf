data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  number_of_azs = length(data.aws_availability_zones.available.names)
  az_names      = data.aws_availability_zones.available.names

  given_public_cidr  = length(keys(var.public_cidr_blocks)) > 0
  given_private_cidr = length(keys(var.private_cidr_blocks)) > 0

  public_cidr_blocks = local.given_public_cidr ? var.public_cidr_blocks : {
    for i, az in local.az_names : az => cidrsubnet(var.cidr_block, 8, i)
  }

  private_cidr_blocks = local.given_private_cidr ? var.private_cidr_blocks : {
    for i, az in local.az_names : az => cidrsubnet(var.cidr_block, 8, i + local.number_of_azs)
  }
}
