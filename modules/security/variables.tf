variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "app_port" {
  description = "Porta da aplicação"
  type        = number
  default     = 80
}

variable "s3_bucket_arn" {
  description = "ARN do bucket S3"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}