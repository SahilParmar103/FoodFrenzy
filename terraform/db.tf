resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier             = "foodfrenzy-db"
  engine                 = "postgres"
  engine_version         = "15.3" # ✅ FIXED from 15.4 to 15.3
  instance_class         = var.rds_instance_class
  username               = var.rds_db_username
  password               = var.rds_db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  allocated_storage      = var.rds_storage_size
  storage_encrypted      = true
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [module.vpc.default_security_group_id]
}
