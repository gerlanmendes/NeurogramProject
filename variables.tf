variable "aws_region" {
  description = "Região da AWS onde a infraestrutura será provisionada"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para identificar os recursos"
  type        = string
  default     = "terraform-aws-infra"
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block para a subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block para a subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidade para os recursos"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH para a instância EC2"
  type        = string
  default     = "my-key-pair"
}

variable "db_instance_class" {
  description = "Classe de instância para o RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Nome do usuário administrador do banco de dados"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Senha do usuário administrador do banco de dados"
  type        = string
  sensitive   = true
}

# terraform.tfvars - Valores para as variáveis

aws_region        = "us-east-1"
project_name      = "terraform-aws-infra"
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone = "us-east-1a"
instance_type     = "t2.micro"
key_name          = "my-key-pair"
db_instance_class = "db.t3.micro"
db_name           = "appdb"
db_username       = "dbadmin"
# db_password = "Your-Secure-Password" # Recomendado fornecer via variável de ambiente ou parâmetro CLI