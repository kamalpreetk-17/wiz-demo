terraform {
  backend "s3" {
    bucket         = "wiz-demo-terraform-tfstate"
    key            = "wiz/infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "wiz-demo-terraform-tfstate-lock"
    encrypt        = true
  }
}