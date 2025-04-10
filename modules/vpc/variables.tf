variable "vpc_cidr_block" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone para os recursos"
  type        = string
}