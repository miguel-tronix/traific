resource "aws_db_subnet_group" "default" {
  name       = "traific-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "traific-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "traific-rds-sg"
  description = "Allow inbound traffic from internal subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "traific-rds-sg"
  }
}

resource "aws_db_instance" "default" {
  identifier           = "traific-postgres"
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.medium"
  username             = "traific_admin"
  password             = var.db_password
  db_name              = "traific_db"
  
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  skip_final_snapshot    = true # For dev/demo only
  publicly_accessible    = false
  
  tags = {
    Name = "traific-rds"
  }
}
