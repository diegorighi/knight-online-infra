output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mssql.endpoint
}

output "address" {
  description = "RDS hostname"
  value       = aws_db_instance.mssql.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.mssql.port
}

output "database_name" {
  description = "Database name (default for MSSQL)"
  value       = "master"
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.mssql.username
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "connection_string" {
  description = "Connection string for Azure Data Studio / SSMS"
  value       = "Server=${aws_db_instance.mssql.address},${aws_db_instance.mssql.port};User Id=${aws_db_instance.mssql.username};Password=<YOUR_PASSWORD>;"
  sensitive   = true
}
