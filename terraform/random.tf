resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "foodfrenzy-project-bucket-${random_id.suffix.hex}"
}
