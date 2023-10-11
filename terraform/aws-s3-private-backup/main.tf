terraform {
  required_version = "~> 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58"
    }
  }
}

provider "aws" {
  region = var.aws_primary_region
  default_tags { tags = local.default_tags }
}

provider "aws" {
  region = var.aws_secondary_region
  alias  = "secondary"
  default_tags { tags = local.default_tags }
}

module "tfstate_backend" {
  count  = terraform.workspace == "default" ? 1 : 0
  source = "github.com/d3adb5/terraform-aws-tfstate-backend?ref=v1.2.0"
  # ^ Switch to upstream once changes have been merged.

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true

  namespace = "d3adb5"
  stage     = "private-backup"
  name      = "tfstate"

  backend_config_filepath = "."
  backend_config_filename = "backend.tf"

  providers = {
    aws.primary   = aws
    aws.secondary = aws.secondary
  }
}

module "backup_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  create_bucket = terraform.workspace != "default"
  bucket        = var.bucket_name
  acl           = "private"

  force_destroy = false

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "glacier-instant-retrieval"
      enabled = true

      transition = [{
        days          = 0
        storage_class = "GLACIER_IR"
      }]
    },
    {
      id      = "glacier-flexible-retrieval-for-old-versions"
      enabled = true

      noncurrent_version_transition = [{
        days          = 120
        storage_class = "GLACIER"
      }]
    }
  ]

  intelligent_tiering = {
    default = {
      status = "Enabled"
      tiering = {
        ARCHIVE_ACCESS      = { days = 120 }
        DEEP_ARCHIVE_ACCESS = { days = 180 }
      }
    }
  }
}
