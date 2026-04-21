terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.infra]
    }
  }
}

data "aws_availability_zones" "available" {
  provider = aws.infra
  state    = "available"
}

// main vpc
resource "aws_vpc" "main" {
  provider   = aws.infra
  cidr_block = var.vpc_cidr
  tags = {
    Name        = "${var.app_name}-main-vpc"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

// private subnet
resource "aws_subnet" "private" {
  provider          = aws.infra
  vpc_id            = aws_vpc.main.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.app_name}-private-subnet-az${count.index + 1}"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
    Type        = "private"
  }
}

// public subnet
resource "aws_subnet" "public" {
  provider          = aws.infra
  vpc_id            = aws_vpc.main.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, 3 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # map_public_ip_on_launch = true
  tags = {
    Name        = "${var.app_name}-public-subnet-az${count.index + 1}"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
    Type        = "public"
  }
}

// database subnet (private)
resource "aws_subnet" "db" {
  provider          = aws.infra
  vpc_id            = aws_vpc.main.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, 6 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.app_name}-db-subnet-az${count.index + 1}"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
    Type        = "private"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "gw" {
  provider = aws.infra
  vpc_id   = aws_vpc.main.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_route_table" "public_route" {
  provider = aws.infra
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name        = "${var.app_name}-public-route"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  provider       = aws.infra
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_route.id
}


