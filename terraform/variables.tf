variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ec2_key_pair" {
  description = "Name of the EC2 Key Pair"
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
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_storage_size" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}
variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "key_name" {
  description = "Key Pair"
  type        = string
}

variable "volume_size" {
  description = "Volume size"
  type        = string
}

variable "region_name" {
  description = "AWS Region"
  type        = string
}

variable "server_name" {
  description = "EC2 Server Name"
  type        = string
}


variable "ec2_private_key" {
  description = "The private SSH key for EC2 remote-exec"
  type        = string
  sensitive   = true
}
