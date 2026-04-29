
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.ap-south-1.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.private_subnet[0].id, var.private_subnet[1].id]
  security_group_ids = [var.demo_sg_id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.ap-south-1.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.private_subnet[0].id, var.private_subnet[1].id]
  security_group_ids = [var.demo_sg_id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.private_route_table_id]
}