# RDS MSSQL Module for Knight Online Database

# Subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS MSSQL"
  vpc_id      = var.vpc_id

  # MSSQL from game server
  ingress {
    description     = "MSSQL from Game Server"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  # MSSQL from admin IPs (for management from Mac)
  ingress {
    description = "MSSQL from Admin"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = var.admin_ip_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

# RDS MSSQL Instance
resource "aws_db_instance" "mssql" {
  identifier = "${var.project_name}-mssql"

  # Engine
  engine         = "sqlserver-ex" # Express Edition (free license)
  engine_version = var.engine_version
  license_model  = "license-included"

  # Instance
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Credentials
  username = var.db_username
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible
  port                   = 1433

  # Maintenance
  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Options
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-final-snapshot"
  deletion_protection       = var.deletion_protection

  # Performance
  performance_insights_enabled = false # Not available on db.t3.micro

  tags = merge(var.tags, {
    Name = "${var.project_name}-mssql"
  })
}
