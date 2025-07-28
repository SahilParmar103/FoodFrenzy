variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "ami" {
  description = "AMI ID"
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
  description = "Private key content to SSH into EC2 instance"
  type        = string
  sensitive   = true
}
variable "vpc_id" {
  description = "The ID of the VPC to associate the security group with"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}
