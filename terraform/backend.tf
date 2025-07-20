terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "bucketforgitact"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
  }
}
