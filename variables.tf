variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    Project     = "terraform-aws-infra"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "terraform-aws-infra"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Availability Zone para os recursos"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome do par de chaves para a instância EC2"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Nome do banco de dados RDS"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Nome de usuário para o banco de dados RDS"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Senha para o banco de dados RDS"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe de instância para o RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "bucket_suffix" {
  description = "Sufixo para o nome do bucket S3 (deve ser globalmente único)"
  type        = string
  default     = "logs"
}

##