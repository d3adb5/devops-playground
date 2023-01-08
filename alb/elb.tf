resource "aws_lb" "default" {
  name                       = var.alb_name
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.default.id]
  subnets                    = var.subnets
  enable_deletion_protection = true

  tags = { Name = var.alb_name }
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = var.alb_port
  protocol          = var.alb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_target_group" "default" {
  name     = var.alb_name
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    path                = var.alb_health_check_path
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = { Name = var.alb_name }
}
