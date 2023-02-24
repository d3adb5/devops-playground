variable "aws_region" {
  type        = string
  description = "AWS region where the resources will be created. Defaults to us-west-2."
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "Project name, used when naming resources. Change only if necessary."
  default     = "terraform-aws-ecs-alb-cloudfront"
}

variable "repository_url" {
  type        = string
  description = "URL of the repository where the project is hosted. Change only if necessary."
  default     = "https://github.com/d3adb5/terraform-playground"
}
