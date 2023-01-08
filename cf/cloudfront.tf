locals {
  origin_id = coalesce(var.domain_name, var.origin_id, random_string.origin_id)
}

# Generate a random Origin ID to make sure it's unique. This is used only if no
# domain or Origin ID is specified through the module's variables.
resource "random_string" "origin_id" {
  length  = 16
  special = false
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Origin access identity for ${local.origin_id}"
}

resource "aws_cloudfront_distribution" "default" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for ${local.origin_id}"
  aliases         = var.aliases

  origin {
    domain_name = var.alb_dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1h
    max_ttl                = 86400 # 1d

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
