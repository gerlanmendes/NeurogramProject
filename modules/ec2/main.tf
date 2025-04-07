# modules/ec2/main.tf - Configuração da instância EC2

# Security Group para EC2
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group para instância EC2"
  vpc_id      = var.vpc_id

  # SSH da Internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Na produção, limitar ao endereço IP específico
    description = "SSH access"
  }

  # HTTP da Internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS da Internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Saída para qualquer lugar
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Project     = var.project_name
    Environment = "production"
  }
}

# IAM Role para EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Project     = var.project_name
    Environment = "production"
  }
}

# Política para acesso ao S3
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access-policy"
  description = "Permite acesso ao bucket S3 de logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Anexar política à role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Instance Profile para EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Atualiza o sistema
              yum update -y
              
              # Instala o Docker
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              # Configura o logging para o S3
              cat > /etc/docker/daemon.json <<'DOCKERCONFIG'
              {
                "log-driver": "awslogs",
                "log-opts": {
                  "awslogs-region": "${data.aws_region.current.name}",
                  "awslogs-group": "/docker/containers",
                  "awslogs-create-group": "true"
                }
              }
              DOCKERCONFIG
              
              systemctl restart docker
              
              # Executa um container NGINX de exemplo
              docker run -d --name nginx -p 80:80 nginx
              
              # Configura rotação de logs e upload para S3
              cat > /etc/cron.daily/docker-logs-to-s3 <<'CRON'
              #!/bin/bash
              LOGS_DIR=/var/lib/docker/containers
              DATE=$(date +%Y%m%d)
              BUCKET=${var.s3_bucket_name}
              
              # Compacta logs do dia anterior
              find $LOGS_DIR -name "*.log" -exec tar -czf /tmp/docker-logs-$DATE.tar.gz {} \;
              
              # Envia para o S3
              aws s3 cp /tmp/docker-logs-$DATE.tar.gz s3://$BUCKET/docker-logs/
              
              # Remove o arquivo temporário
              rm -f /tmp/docker-logs-$DATE.tar.gz
              CRON
              
              chmod +x /etc/cron.daily/docker-logs-to-s3
              EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-ec2-instance"
    Project     = var.project_name
    Environment = "production"
  }
}

# Data source para obter a AMI mais recente do Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source para obter a região atual
data "aws_region" "current" {}

# modules/ec2/variables.tf
variable "project_name" {
  description = "Nome do projeto para identificar os recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde a instância será criada"
  type        = string
}

variable "public_subnet_id" {
  description = "ID da subnet pública onde a instância será criada"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH para a instância EC2"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para logs"
  type        = string
}

# modules/ec2/outputs.tf
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
  value       = aws_security_group.ec2_sg.id
}