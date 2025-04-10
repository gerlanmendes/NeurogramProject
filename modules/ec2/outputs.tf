output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.app_server.public_ip
}

output "security_group_id" {
  description = "ID do security group da EC2"
  value       = aws_security_group.ec2.id
}