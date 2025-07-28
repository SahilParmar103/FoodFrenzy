terraform {
  backend "s3" {
    bucket         = "bucketforgitact"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
  }
}
