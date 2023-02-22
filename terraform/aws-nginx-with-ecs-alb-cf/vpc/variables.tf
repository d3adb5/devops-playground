variable "enabled" {
  type        = bool
  description = "Whether to create any resources."
  default     = true
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_cidr_blocks" {
  type        = map(string)
  description = "Map of AWS availability zone to CIDR block for public subnets."
  default     = {}
}

variable "private_cidr_blocks" {
  type        = map(string)
  description = "Map of AWS availability zone to CIDR block for private subnets."
  default     = {}
}
