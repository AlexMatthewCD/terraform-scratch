resource "aws_alb" "demo_alb" {
  name                       = "${var.app_name}-${var.env_name}-alb"
  subnets                    = [for s in var.public_subnet : s.id]
  security_groups            = [var.demo_sg_id]
  idle_timeout               = 300
  enable_deletion_protection = false

  tags = {
    Name        = "${var.app_name}-demo-alb"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_lb_target_group" "api_backend_tg" {
  name        = "${var.app_name}-${var.env_name}-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "3000"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-api-tg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_alb.demo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_backend_tg.arn
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_inbound" {
  security_group_id = var.demo_sg_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = var.demo_sg_id
  referenced_security_group_id = var.demo_sg_id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}