variable "aws_primary_region" {
  description = "AWS region for most of the resources used in this module."
  default     = "us-west-2"
  type        = string
}

variable "aws_secondary_region" {
  description = "AWS region for the 2nd backend bucket when replication is on."
  default     = "us-west-1"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket that'll store our backups."
  default     = "d3adb5-private-bucket"
  type        = string
}
