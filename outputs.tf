output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID da subnet pública"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = module.vpc.private_subnet_id
}

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = module.rds.rds_endpoint
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 para logs"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.s3.bucket_arn
}