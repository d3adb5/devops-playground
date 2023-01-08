variable "alb_name" {
  type        = string
  description = "Name of the Application Load Balancer to be provisioned."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.alb_name))
    error_message = "The ALB name can only contain alphanumeric characters and hyphens."
  }
}

variable "alb_health_check_path" {
  type        = string
  description = "Path to use for health checks."
  default     = "/"
}

variable "alb_port" {
  type        = string
  description = "Port on which the ALB will listen for requests."

  validation {
    condition     = var.alb_port >= 1 && var.alb_port <= 65535
    error_message = "The ALB port must be between 1 and 65535."
  }
}

variable "alb_protocol" {
  type        = string
  description = "Protocol for connections from clients to the ALB."
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.alb_protocol)
    error_message = "The ALB protocol must be either HTTP or HTTPS."
  }
}

variable "target_port" {
  type        = string
  description = "The port on which the targets of this ALB are listening."

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "The target port must be between 1 and 65535."
  }
}

variable "target_protocol" {
  type        = string
  description = "Protocol to use for routing traffic to the targets."
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "The target protocol must be either HTTP or HTTPS."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to be used for the ALB."

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "The VPC ID must be in the format vpc-xxxxxx..."
  }
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets the ALB will be provisioned in."

  validation {
    condition     = length(var.subnets) > 1
    error_message = "Must specify at least two subnets in different AZs."
  }
}
