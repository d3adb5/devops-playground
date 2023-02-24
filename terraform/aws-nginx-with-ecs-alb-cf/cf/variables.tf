variable "domain_name" {
  type        = string
  description = "The domain name for the CloudFront distribution."
  default     = ""
}

variable "origin_id" {
  type        = string
  description = "The origin ID for the CloudFront distribution. Used if no domain name is specified."
  default     = ""
}

variable "aliases" {
  type        = list(string)
  description = "A list of domains that you want to use with this distribution."
  default     = []
}

variable "alb_dns_name" {
  type        = string
  description = "The DNS name of the ALB to use as the origin."

  validation {
    condition     = length(var.alb_dns_name) > 0
    error_message = "The ALB DNS name must be specified."
  }
}
