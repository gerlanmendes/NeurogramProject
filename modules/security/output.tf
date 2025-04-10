output "ec2_security_group_id" {
  description = "ID do security group da instância EC2"
  value       = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  description = "ID do security group do RDS"
  value       = aws_security_group.rds_sg.id
}

output "ec2_instance_profile" {
  description = "Nome do perfil de instância EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_iam_role_name" {
  description = "Nome da IAM role para EC2"
  value       = aws_iam_role.ec2_s3_access.name
}