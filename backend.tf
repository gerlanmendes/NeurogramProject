terraform {
  backend "s3" {
    #Você deve criar este bucket manualmente ou usar um local backend para teste
    bucket = "terraform-state-bucket-name"
    key    = "terraform/state/terraform.tfstate"
    region = "us-east-1"
    #Recomendado para produção:
    #dynamodb_table = "terraform-locks"
    #encrypt        = true
  }
}