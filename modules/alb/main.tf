terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.infra]
    }
  }
}

resource "aws_alb" "demo_alb" {
  provider                   = aws.infra
  name                       = "${var.app_name}-${var.env_name}-alb"
  subnets                    = [for s in var.public_subnet : s.id]
  security_groups            = [var.demo_sg_id]
  idle_timeout               = 300
  enable_deletion_protection = false

  tags = {
    "Name"        = "${var.app_name}-demo_alb"
    "Environment" = "${var.env_name}"
    "Application" = var.app_name
    "CostCenter"  = var.cost_center
  }
}