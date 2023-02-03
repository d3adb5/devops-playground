output "distribution_id" {
  value = aws_cloudfront_distribution.default.id
}

output "distribution_domain" {
  value = aws_cloudfront_distribution.default.domain_name
}
