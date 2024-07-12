terraform {
  backend "s3" {
    bucket  = "mahalohub" 
    key     = "terraform-backend.tfstate"
    region  = "us-east-1"
    encrypt = false
  }
}