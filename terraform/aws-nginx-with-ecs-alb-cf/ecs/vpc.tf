data "aws_lb" "default" {
  arn = var.alb_arn
}

resource "aws_security_group" "default" {
  name        = "${var.cluster_name}-${var.service_name}"
  description = "Allow inbound traffic from the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = data.aws_lb.default.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
