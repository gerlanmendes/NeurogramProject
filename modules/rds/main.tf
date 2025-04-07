# modules/rds/main.tf - Configuração do RDS

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group para instância RDS"
  vpc_id      = var.vpc_id

  # Acesso PostgreSQL apenas da EC2
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
    description     = "PostgreSQL access from EC2"
  }

  # Nenhuma saída por padrão
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow necessary outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Project     = var.project_name
    Environment = "production"
  }
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = var.db_subnet_group_name
  description = "Subnet group para RDS"
  subnet_ids  = [var.private_subnet_id]

  tags = {
    Name        = "${var.project_name}-rds-subnet-group"
    Project     = var.project_name
    Environment = "production"
  }
}

# Parameter Group para PostgreSQL
resource "aws_db_parameter_group" "postgres" {
  name        = "${var.project_name}-postgres-params"
  family      = "postgres13"
  description = "Parameter group para PostgreSQL"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name        = "${var.project_name}-postgres-params"
    Project     = var.project_name
    Environment = "production"
  }
}

# Instância RDS
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres"
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:30-Mon:05:30"
  deletion_protection    = true

  tags = {
    Name        = "${var.project_name}-rds-postgres"
    Project     = var.project_name
    Environment = "production"
  }
}

# modules/rds/variables.tf
variable "project_name" {
  description = "Nome do projeto para identificar os recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será criado"
  type        = string
}

variable "private_subnet_id" {
  description = "ID da subnet privada onde o RDS será criado"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Nome do subnet group para RDS"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID do security group da EC2 que terá acesso ao RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Classe de instância para o RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Nome do usuário administrador do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário administrador do banco de dados"
  type        = string
  sensitive   = true
}

# modules/rds/outputs.tf
output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "security_group_id" {
  description = "ID do security group do RDS"
  value       = aws_security_group.rds_sg.id
}