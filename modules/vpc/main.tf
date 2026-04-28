data "aws_availability_zones" "available" {}

// main vpc
resource "aws_vpc" "main" {
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
  vpc_id            = aws_vpc.main.id
  count             = var.az_count
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
  vpc_id            = aws_vpc.main.id
  count             = var.az_count
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
  vpc_id            = aws_vpc.main.id
  count             = var.az_count
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
  vpc_id   = aws_vpc.main.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_eip" "ip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.gw ]

  tags = {
    Name        = "${var.app_name}-public-route"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_nat_gateway" "gw" {
  subnet_id = aws_subnet.public[0].id
  allocation_id = aws_eip.ip.id
  tags = {
    Name        = "${var.app_name}-nat-gw"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}
resource "aws_route_table" "public_route" {
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

resource "aws_route_table_association" "public_subnet_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public_route[*].id, count.index)
}

resource "aws_route_table" "private_route" {
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name        = "${var.app_name}-private-route"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private_route[*].id, count.index)
}

resource "aws_route_table" "db_route" {
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name        = "${var.app_name}-db-route"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_route_table_association" "db_subnet_association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.db[*].id, count.index)
  route_table_id = element(aws_route_table.db_route[*].id, count.index)
  
}