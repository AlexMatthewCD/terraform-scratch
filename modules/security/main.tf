resource "aws_security_group" "demo" {
  name        = "${var.app_name}-demo-sg"
  description = "Allow traffic from the internet to ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name       = "${var.app_name}-demo-sg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo_inbound" {
  security_group_id = aws_security_group.demo.id

  description = "Allow HTTPS"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "demo_outbound" {
  security_group_id = aws_security_group.demo.id

  description = "Allow any traffic going out"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
}