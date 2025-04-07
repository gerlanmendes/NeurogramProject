# modules/s3/main.tf - Configuração do bucket S3

# Bucket S3 para logs
resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Project     = var.project_name
    Environment = "production"
  }
}

# Configuração de versionamento
resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuração de criptografia do bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configuração de política de ciclo de vida
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    # Mover para armazenamento infrequent access após 30 dias
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Mover para Glacier após 90 dias
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Expirar após 365 dias
    expiration {
      days = 365
    }
  }
}

# Bloqueio de acesso público ao bucket
resource "aws_s3_bucket_public_access_block" "logs_public_access" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política de acesso ao bucket
resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.logs_public_access]
}

# modules/s3/variables.tf
variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto para identificar os recursos"
  type        = string
}

# modules/s3/outputs.tf
output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.logs.id
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.logs.arn
}