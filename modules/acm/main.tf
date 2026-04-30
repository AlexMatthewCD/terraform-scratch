provider "aws" {
  region  = "us-east-1"
  profile = "edtech-nonprod"
  alias   = "dns-record"
}

provider "aws" {
  region = "us-east-1"
  profile = "cd-sandbox"
  alias   = "cf-acm-cert"
}

provider "aws" {
  region                  = "ap-southeast-2"
  alias                   = "alb-acm-cert"
  profile                 = "cd-sandbox"
}
data "aws_route53_zone" "domain" {
  provider = aws.dns-record
  name     = var.main_domain_name
}

resource "aws_acm_certificate" "cf_certificate" {
  domain_name       = "latrobe.${var.main_domain_name}"
  validation_method = "DNS"
  provider = aws.cf-acm-cert

  tags = {
    Name        = "${var.app_name}-cf-certificate"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }

  lifecycle {
    create_before_destroy = true
  }
}

// attach certificate
resource "aws_route53_record" "cf_domain_record" {
  provider = aws.dns-record
  for_each = {
    for dvo in aws_acm_certificate.cf_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.domain.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider = aws.cf-acm-cert
  certificate_arn         = aws_acm_certificate.cf_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cf_domain_record : record.fqdn]
}


#Create certificate for ALB
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.alb_domain_name
  provider          = aws.alb-acm-cert
  validation_method = "DNS"

  tags = {
    "Name"        = "${var.app_name}-${var.env_name}-alb-acm"
    "Environment" = "${var.app_name}-${var.env_name}"
    "Application" = var.app_name
    "CostCenter" = var.cost_center
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Attach the certificate For SIM ALB to Route53
resource "aws_route53_record" "alb_domain_record" {
  provider = aws.dns-record
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

#Validate Wildcard certificate For SIM ALB
resource "aws_acm_certificate_validation" "alb_certificate_validation" {
  provider                = aws.alb-acm-cert
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_domain_record : record.fqdn]
}