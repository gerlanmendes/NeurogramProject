output "ec2_role_name" {
  description = "Nome da role IAM para EC2"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_role_arn" {
  description = "ARN da role IAM para EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "Nome do perfil de instância IAM"
  value       = aws_iam_instance_profile.ec2_profile.name
}