variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "bucket_suffix" {
  description = "Sufixo para o nome do bucket S3 (deve ser globalmente único)"
  type        = string
}