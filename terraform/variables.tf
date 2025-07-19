variable "aws_region" {
  default = "us-east-1"
}

variable "ec2_key_pair" {
  description = "The name of the EC2 Key Pair"
  type        = string
}

variable "rds_db_username" {
  description = "RDS master username"
  type        = string
}

variable "rds_db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "rds_instance_class" {
  default = "db.t3.micro"
}

variable "rds_storage_size" {
  default = 20
}
