data "aws_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "default" {
  name        = var.alb_name
  description = "Security group for ALB ${var.alb_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = data.aws_prefix_list.cloudfront.cidr_blocks
  }
}
