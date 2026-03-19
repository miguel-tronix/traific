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
  allocated_storage    = 50
  max_allocated_storage = 200
  storage_type         = "gp3"
  storage_encrypted    = true
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.medium"
  username             = "traific_admin"
  password             = var.db_password
  db_name              = "traific_db"

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  multi_az                = true

  skip_final_snapshot    = false
  final_snapshot_identifier = "traific-final-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  publicly_accessible    = false

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "traific-rds"
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "traific-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "null_resource" "enable_postgis" {
  triggers = {
    db_host = aws_db_instance.default.address
  }

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${var.db_password}' psql \
        --host='${aws_db_instance.default.address}' \
        --port=5432 \
        --username=traific_admin \
        --dbname=traific_db \
        --command="CREATE EXTENSION IF NOT EXISTS postgis;" \
        --command="CREATE EXTENSION IF NOT EXISTS postgis_raster;" \
        --command="CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
    EOT
  }

  depends_on = [aws_db_instance.default]
}
