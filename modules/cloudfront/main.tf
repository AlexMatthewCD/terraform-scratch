provider "aws" {
  region = "us-east-1"
  alias = "dns-record"
  profile = "edtech-nonprod"
}

data "aws_wafv2_web_acl" "waf_acl" {
  name = "sandbox-global-waf-protection"
  scope = "CLOUDFRONT"
  region = "us-east-1"
  
}

resource "aws_cloudfront_origin_access_identity" "cdn_access_identity" {
  comment = "origin access identity for cloudfront"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.s3_static
    origin_id   = "${var.app_name}-${var.env_name}-static-bucket"
    origin_access_control_id    = "EFH6GNRM9GNJ8"
  }
  default_root_object = "index.html"
  enabled             = true
  lifecycle {
    prevent_destroy = false
  }
  # aliases = [var.frontend_domain_name, var.alb_domain_name, var.authentik_domain_name, var.client_auth_domain_name, var.client_domain_name] // For Prod
  aliases = [var.frontend_domain_name] // For Staging

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.app_name}-${var.env_name}-static-bucket"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      headers      = []

      cookies {
        forward = "all"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.nv_cf_certificate
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = data.aws_wafv2_web_acl.waf_acl.arn

  tags = {
    "Name"        = "${var.app_name}-${var.env_name}-cdn"
    "Environment" = "${var.app_name}-${var.env_name}"
    "Application" = var.app_name
    "CostCenter"  = var.cost_center
  }
}

data "aws_route53_zone" "cdn_domain" {
  name     = var.main_domain_name
  provider = aws.dns-record
}

resource "aws_route53_record" "cdn_domain_record" {
  provider = aws.dns-record
  zone_id  = data.aws_route53_zone.cdn_domain.zone_id

  allow_overwrite = true
  name            = var.frontend_domain_name
  type            = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}