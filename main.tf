terraform {
  required_version = "~> 1.2"

  required_providers {
    aws = "~> 4.48"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Workspace  = terraform.workspace
      Repository = var.repository_url
      Project    = var.project_name
    }
  }
}

module "terraform_state_backend" {
  enabled = terraform.workspace == "default"
  source  = "cloudposse/tfstate-backend/aws"
  version = "0.38.1"

  namespace = var.project_name
  stage     = terraform.workspace
  name      = "tfstate"

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false

  terraform_version = "1.2"
}

# Temporary fix for a deprecation in version 0.38.1 of the backend module being
# used above. A warning will still be issued, but this resource should apply the
# desired configuration.

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = module.terraform_state_backend.s3_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
