variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster to be created by this configuration."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.cluster_name)) && length(var.cluster_name) > 0
    error_message = "Invalid cluster name: invalid length or characters."
  }
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service to be created by this configuration."
}

variable "replica_count" {
  type        = number
  description = "Number of replicas to be created for the service."
  default     = 1

  validation {
    condition     = var.replica_count > 0
    error_message = "Replica count must be greater than 0."
  }
}

variable "task_definition_name" {
  type        = string
  description = "Name of the ECS task definition to be created by this configuration."
}

variable "ssm_parameter_arns" {
  type        = list(string)
  description = "List of SSM Parameter ARNs to be made available to the task definition."
  default     = []
}

variable "health_check" {
  description = "Health check configuration for the container."

  type = object({
    command     = list(string)
    interval    = optional(number) # Defaults to 30 seconds.
    retries     = optional(number) # Defaults to 3 retries.
    startPeriod = optional(number) # Defaults to 0 seconds.
    timeout     = optional(number) # Defaults to 5 seconds.
  })

  validation {
    condition     = length(var.health_check.command) > 0
    error_message = "Health check command must be specified."
  }
}

variable "container_port" {
  type        = number
  description = "Port on which the container is listening."

  validation {
    condition     = var.container_port > 0 && var.container_port < 65536
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "cpu_in_millicores" {
  type        = number
  description = "CPU units to be allocated to the container, measured in millicores."

  validation {
    condition     = var.cpu_in_millicores >= 128 && var.cpu_in_millicores <= 10240
    error_message = "CPU units must be between 128 and 10240."
  }
}

variable "memory_in_megabytes" {
  type        = number
  description = "Memory to be allocated to the container, measured in megabytes."

  validation {
    condition     = var.memory_in_megabytes >= 256 && var.memory_in_megabytes <= 30720
    error_message = "Memory must be between 256 and 30720."
  }
}

variable "image_repository" {
  type        = string
  description = "Repository from which the container image will be pulled."

  validation {
    condition     = length(var.image_repository) > 0
    error_message = "Image repository must be specified."
  }
}

variable "image_tag" {
  type        = string
  description = "Tag of the image to be deployed."

  validation {
    condition     = length(var.image_tag) > 0
    error_message = "Image tag must be specified."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which the ECS cluster will be created."

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID must be specified and follow the format vpc-xxxx..."
  }
}

variable "alb_arn" {
  type        = string
  description = "ARN of the Application Load Balancer to which the service will be attached."

  validation {
    condition     = length(var.alb_arn) > 0
    error_message = "Application Load Balancer ARN must be specified."
  }
}

variable "alb_target_group_arn" {
  type        = string
  description = "ARN of the target group to which the service will be attached."

  validation {
    condition     = length(var.alb_target_group_arn) > 0
    error_message = "Application Load Balancer target group ARN must be specified."
  }
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs in which the ECS service will be created."

  validation {
    condition     = length(var.subnets) > 0
    error_message = "Must specify at least one subnet."
  }
}
