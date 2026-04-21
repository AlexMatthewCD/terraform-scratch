terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.infra, aws.dns]
    }
  }
}

locals {
  s3_origin_id = "${var.app_name}-${var.env_name}-s3-origin"
  my_domain    = "alex-learn.${var.domain_name}"
}

data "aws_cloudfront_cache_policy" "disabled" {
  provider = aws.infra
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_origin_access_control" "default" {
    provider = aws.infra
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    provider = aws.infra
    comment             = "Distribution for the demo website"
    aliases = ["alex-learn.crystaldelta.net"]
  origin {
    domain_name              = var.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }
  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    cache_policy_id        = data.aws_cloudfront_cache_policy.disabled.id
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  tags = {
    Name        = "${var.app_name}-demo-cdn"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate.arn
    ssl_support_method  = "sni-only"
  }
}

data "aws_route53_zone" "domain" {
  provider = aws.dns
  name     = var.domain_name
}

resource "aws_route53_record" "website" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.domain.zone_id
  name     = "alex-learn.${var.domain_name}"
  type     = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}