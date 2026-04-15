data "aws_availability_zones" "available" {
  state = "available"
}

// main vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.app_name}-main-vpc"
    Environment = var.env_name
  }
}

// private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(var.vpc_cidr, 6, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.app_name}-private-subnet-az${count.index + 1}"
    Environment = var.env_name
  }
}

// public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(var.vpc_cidr, 6, 3 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.app_name}-public-subnet-az${count.index + 1}"
    Environment = var.env_name
  }
}

// database subnet (private)
resource "aws_subnet" "db" {
  vpc_id = aws_vpc.main.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(var.vpc_cidr, 6, 6 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.app_name}-db-subnet-az${count.index + 1}"
    Environment = var.env_name
  }
}