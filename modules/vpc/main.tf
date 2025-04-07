# modules/vpc/main.tf - Configuração da VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "production"
  }
}

# Subnet pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Project     = var.project_name
    Environment = "production"
  }
}

# Subnet privada
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Project     = var.project_name
    Environment = "production"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = "production"
  }
}

# Route Table para subnet pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Project     = var.project_name
    Environment = "production"
  }
}

# Associação de Route Table com subnet pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route Table para subnet privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = "production"
  }
}

# Associação de Route Table com subnet privada
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Network ACL
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]

  # Permita todo tráfego de saída
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Permita todo tráfego de entrada
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.project_name}-nacl"
    Project     = var.project_name
    Environment = "production"
  }
}

# modules/vpc/variables.tf
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block para subnet pública"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block para subnet privada"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidade para os recursos"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto para identificar os recursos"
  type        = string
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = aws_subnet.private.id
}