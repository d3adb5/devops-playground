output "alb_arn" {
  value = aws_lb.default.arn
}

output "alb_dns_name" {
  value = aws_lb.default.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.default.arn
}
