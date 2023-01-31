resource "aws_db_instance" "main_db" {
  allocated_storage    = 10
  db_name              = "testssh"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  username             = "metabase"
  password             = "metasample123"
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  storage_type         = "gp2"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  tags = {
    Name = "main_db"
  }
  availability_zone = "us-east-1a"
  multi_az = "false"
  backup_retention_period = 0
  publicly_accessible = "false"
  storage_encrypted = "true"
  deletion_protection = "false"
  apply_immediately = "true"
  auto_minor_version_upgrade = "true"
  copy_tags_to_snapshot = "true"
  monitoring_interval = 0
}

output "rds_address" {
  value = aws_db_instance.main_db.address
}