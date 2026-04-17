data "aws_route53_zone" "domain" {
    provider = aws.dns
  name     = var.domain_name
}

# data "aws_s3_bucket" "site" {
#   provider = aws.dns
#   bucket = "scratch.iemsdev.online"
# }

resource "aws_route53_record" "scratch" {
  provider = aws.dns
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "scratch.${var.domain_name}"
  records = ["scratch.iemsdev.online.s3-website.ap-south-1.amazonaws.com"]
  type    = "CNAME"
  ttl     = 300
}

// create certificate
resource "aws_acm_certificate" "certificate" {
  provider          = aws.infra
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "${var.app_name}-demo-certificate"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }

  lifecycle {
    create_before_destroy = true
  }
}

// attach certificate
resource "aws_route53_record" "attach_record" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id = data.aws_route53_zone.domain.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.infra
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.attach_record : record.fqdn]
}