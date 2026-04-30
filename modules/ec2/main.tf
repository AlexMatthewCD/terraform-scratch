data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "main_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.small"
  vpc_security_group_ids = [var.ec2_sg_id]
  subnet_id              = var.private_subnet_id
  disable_api_termination = true
  associate_public_ip_address = false
  key_name = "latrobe-stg-key"
  root_block_device {
    volume_type           = "gp3"
    volume_size           = "20"
    delete_on_termination = true

    tags = {
      Name        = "${var.app_name}-${var.env_name}-ec2"
      Environment = var.env_name
      Application = var.app_name
      CostCenter  = var.cost_center
    }
  }

  tags = {
    Name        = "${var.app_name}-${var.env_name}-ec2"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_instance" "bastion_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  vpc_security_group_ids = [var.bastion_sg_id]
  subnet_id              = var.public_subnet_id
  disable_api_termination = true
  associate_public_ip_address = false
  key_name = "latrobe-stg-key"

  root_block_device {
    volume_type           = "gp3"
    volume_size           = "20"
    delete_on_termination = true

    tags = {
      Name        = "${var.app_name}-${var.env_name}-bastion"
      Environment = var.env_name
      Application = var.app_name
      CostCenter  = var.cost_center
    }
  }

  tags = {
    Name        = "${var.app_name}-${var.env_name}-bastion"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}