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

module "vpc" {
  enabled = terraform.workspace == "default"
  source  = "./vpc"
}

module "alb" {
  count  = terraform.workspace == "default" ? 0 : 1
  source = "./alb"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  alb_name              = var.project_name
  alb_health_check_path = "/"
  alb_port              = 80
  alb_protocol          = "HTTP"

  target_port     = 80
  target_protocol = "HTTP"
}

module "ecs" {
  count  = terraform.workspace == "default" ? 0 : 1
  source = "./ecs"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  cluster_name         = var.project_name
  service_name         = var.project_name
  task_definition_name = var.project_name

  alb_arn              = module.alb[0].alb_arn
  alb_target_group_arn = module.alb[0].alb_target_group_arn

  image_repository = "nginx"
  image_tag        = "latest"
  container_port   = 80

  cpu_in_millicores   = 256
  memory_in_megabytes = 512

  health_check = {
    command = split(" ", "curl http://localhost/")
  }
}

module "cf" {
  count  = terraform.workspace == "default" ? 0 : 1
  source = "./cf"

  alb_dns_name = module.alb[0].alb_dns_name
}
