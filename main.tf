# VPC e componentes de rede
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block    = var.vpc_cidr_block
  project_name      = var.project_name
  environment       = var.environment
  availability_zone = var.availability_zone
}

# IAM Roles e Policies
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  bucket_name  = module.s3.bucket_name
}

# EC2 com Docker
module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  rds_endpoint       = module.rds.rds_endpoint
  rds_username       = var.db_username
  rds_password       = var.db_password
  rds_database       = var.db_name

  depends_on = [module.vpc, module.rds, module.iam]
}

# RDS PostgreSQL
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_subnet_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  ec2_security_group_id = module.ec2.security_group_id

  depends_on = [module.vpc]
}

# S3 Bucket para Logs
module "s3" {
  source = "./modules/s3"

  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = var.bucket_suffix
}