variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet pública"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome do par de chaves para a instância EC2"
  type        = string
}

variable "iam_instance_profile" {
  description = "Nome do perfil de instância IAM"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint do RDS"
  type        = string
}

variable "rds_username" {
  description = "Nome de usuário do RDS"
  type        = string
}

variable "rds_password" {
  description = "Senha do RDS"
  type        = string
  sensitive   = true
}

variable "rds_database" {
  description = "Nome do banco de dados RDS"
  type        = string
}