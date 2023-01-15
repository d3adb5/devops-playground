data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  number_of_azs = length(data.aws_availability_zones.available.names)
  az_names      = data.aws_availability_zones.available.names

  public_cidr_blocks = var.public_cidr_blocks ? var.public_cidr_blocks : {
    for i, az in local.az_names : az => cidrsubnet(var.cidr_block, 8, i)
  }

  private_cidr_blocks = var.private_cidr_blocks ? var.private_cidr_blocks : {
    for i, az in local.az_names : az => cidrsubnet(var.cidr_block, 8, i + local.number_of_azs)
  }
}
