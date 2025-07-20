resource "aws_ecr_repository" "app_repo" {
  name                 = "foodfrenzy"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "foodfrenzy"
    Environment = "dev"
    Terraform   = "true"
  }
}
