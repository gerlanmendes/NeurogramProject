# modules/rds/outputs.tf

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "security_group_id" {
  description = "ID do security group do RDS"
  value       = aws_security_group.rds_sg.id
}