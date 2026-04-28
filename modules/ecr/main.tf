resource "aws_ecr_repository" "connnect_ecr" {
  name = "${var.app_name}-${var.env_name}-api-ecr"

  tags = {
    Name        = "${var.app_name}-api-ecr"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}
