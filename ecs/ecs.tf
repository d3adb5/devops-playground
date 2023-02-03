resource "aws_ecs_cluster" "default" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = var.cluster_name }
}

resource "aws_ecs_service" "default" {
  name          = var.service_name
  cluster       = aws_ecs_cluster.default.id
  desired_count = var.replica_count

  task_definition = join(":", [
    aws_ecs_task_definition.default.family,
    aws_ecs_task_definition.default.revision
  ])

  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  force_new_deployment = true

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.default.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_port   = var.container_port
    container_name   = "application"
  }

  tags = { Name = var.service_name }
}

resource "aws_ecs_task_definition" "default" {
  family                   = var.task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution_role.arn

  cpu    = var.cpu_in_millicores
  memory = var.memory_in_megabytes

  container_definitions = jsonencode([
    {
      essential   = true
      name        = "application"
      image       = "${var.image_repository}:${var.image_tag}"
      networkMode = "awsvpc"

      cpu    = var.cpu_in_millicores
      memory = var.memory_in_megabytes

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = local.health_check
      environment = var.environment
      volumesFrom = local.volumes_from
      mountPoints = local.mount_points
    }
  ])

  tags = { Name = var.task_definition_name }
}
