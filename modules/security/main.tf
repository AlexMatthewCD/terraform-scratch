resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow traffic from the internet to ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.app_name}-alb-sg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow any traffic going out"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.app_name}-ec2-sg"
  description = "Allow traffic to EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.app_name}-ec2-sg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "Allow SSH"
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "Allow any traffic going out"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.app_name}-bastion-sg"
  description = "Allow traffic to Bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.app_name}-bastion-sg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_inbound" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow SSH"
  cidr_ipv4         = "103.124.152.135/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_outbound" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow any traffic going out"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-sg"
  description = "Allow traffic to RDS instances"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.app_name}-rds-sg"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_inbound" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow PostgreSQL"
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_outbound" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow any traffic going out"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = -1
}