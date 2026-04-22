resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = [] // 2 subnets inside this list

  tags = {
    Name        = "${var.app_name}-db-subnet-group"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_db_instance" "mvr_db_instance" {
  allocated_storage       = 20
  max_allocated_storage   = 50
  engine                  = "postgres"
  engine_version          = 17.7 // 17.7 (R1) is LTS but 17.2 is R3
  instance_class          = "db.t4g.small"
  identifier              = "${var.app_name}-${var.env_name}-db"
  db_name                 = "${var.app_name}_${var.env_name}_db"
  username                = ""
  password                = ""
  vpc_security_group_ids  = [] // db and lambda sg
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.id
  backup_retention_period = 30
  multi_az                = false // 
  #   kms_key_id                   = ""
  copy_tags_to_snapshot        = true // or false is default
  auto_minor_version_upgrade   = true // idk
  allow_major_version_upgrade  = true // idk
  storage_encrypted            = true
  deletion_protection          = true
  maintenance_window           = "Sat:21:00-Sat:23:00" // idk
  backup_window                = "02:00-04:00"         // idk
  ca_cert_identifier           = "rds-ca-rsa2048-g1"   // or use rds-ca-rsa4096-g1
  skip_final_snapshot          = true
  performance_insights_enabled = true
  monitoring_interval          = 60

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  tags = {
    Name        = "${var.app_name}-db"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}
