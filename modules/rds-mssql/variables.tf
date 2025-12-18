variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to RDS"
  type        = list(string)
  default     = []
}

variable "admin_ip_cidrs" {
  description = "Admin IP CIDRs for direct database access"
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro" # Smallest available for MSSQL
}

variable "engine_version" {
  description = "MSSQL engine version"
  type        = string
  default     = "15.00" # SQL Server 2019
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocated storage for autoscaling (0 to disable)"
  type        = number
  default     = 50
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  default     = "koadmin"
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "publicly_accessible" {
  description = "Make RDS publicly accessible (for admin access from Mac)"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true # Set to false for production
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false # Set to true for production
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
