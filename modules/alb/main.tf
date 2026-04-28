provider "aws" {
  region = "us-east-1"
  profile = "edtech-nonprod"
  alias = "dns-record"
}
resource "aws_lb" "wiki_alb" {
  name                       = "${var.app_name}-${var.env_name}-alb"
  load_balancer_type = "application"
  subnets                    = [for s in var.public_subnet : s.id]
  security_groups            = [var.alb_sg_id]
  idle_timeout               = 300
  enable_deletion_protection = false

  tags = {
    "Name"        = "${var.app_name}-wiki_alb"
    "Environment" = "${var.env_name}"
    "Application" = var.app_name
    "CostCenter"  = var.cost_center
  }
}

resource "aws_lb_target_group" "wiki_alb_tg" {
  name = "${var.app_name}-${var.env_name}-wiki-alb-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 5
    interval = 30
    path = "/"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.wiki_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wiki_alb_tg.arn
  }
}

resource "aws_lb_listener_rule" "wiki_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wiki_alb_tg.arn
  }

  condition {
    host_header {
      values = ["wiki.${var.main_domain_name}"]
    }
  }
}

data "aws_route53_zone" "domain" {
  provider = aws.dns-record
  name     = var.main_domain_name
}

resource "aws_route53_record" "wiki" {
  provider = aws.dns-record
  name    = "wiki.${var.main_domain_name}"
  zone_id = data.aws_route53_zone.domain.zone_id
  type    = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.wiki_alb.dns_name
    zone_id                = aws_lb.wiki_alb.zone_id
    evaluate_target_health = true
  }
}