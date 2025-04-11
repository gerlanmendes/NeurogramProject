aws_region       = "us-east-1"
project_name     = "terraform-aws-infra"
environment      = "dev"
vpc_cidr_block   = "10.0.0.0/16"
availability_zone = "us-east-1a"
instance_type    = "t2.micro"
key_name         = "my-key-pair"
db_name          = "appdb"
db_username      = "dbadmin"
db_password      = "YourStrongPasswordHere" 
db_instance_class = "db.t3.micro"
bucket_suffix    = "logs-123456789"  

default_tags = {
  Project     = "terraform-aws-infra"
  Environment = "dev"
  ManagedBy   = "terraform"
  Owner       = "DevOps"
}

#