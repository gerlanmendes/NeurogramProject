# main.tf - Arquivo principal de configuração

provider "aws" {
  region = var.aws_region
}

# Configuração do backend para armazenar o estado do Terraform
terraform {
  backend "s3" {
    # Estas configurações devem ser substituídas ou definidas via -backend-config
    bucket         = "terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Módulo de VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr   = var.private_subnet_cidr
  availability_zone     = var.availability_zone
  project_name          = var.project_name
}

# Módulo de EC2
module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  s3_bucket_name    = module.s3.bucket_name
  depends_on        = [module.vpc]
}

# Módulo de RDS
module "rds" {
  source = "./modules/rds"

  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_id   = module.vpc.private_subnet_id
  db_subnet_group_name = "${var.project_name}-subnet-group"
  ec2_sg_id           = module.ec2.security_group_id
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  depends_on          = [module.vpc]
}

# Módulo de S3
module "s3" {
  source = "./modules/s3"

  bucket_name = "${var.project_name}-logs-${random_string.suffix.result}"
  project_name = var.project_name
}

# Gerador de string aleatória para nomes únicos de recursos
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}