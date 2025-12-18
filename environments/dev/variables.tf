variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "knight-online-dev"
}

# Network
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Security
variable "admin_ip_cidrs" {
  description = "CIDR blocks for admin access (your IP)"
  type        = list(string)
  # IMPORTANT: Replace with your IP before applying!
  # Example: ["YOUR.IP.ADDRESS.HERE/32"]
}

# Key Pair
variable "create_key_pair" {
  description = "Create new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public SSH key content"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing AWS key pair"
  type        = string
  default     = ""
}

# Game Server
variable "game_server_instance_type" {
  description = "Instance type for game server"
  type        = string
  default     = "t3.medium" # 2 vCPU, 4GB RAM - Good for testing
}

variable "game_server_volume_size" {
  description = "Root volume size for game server (GB)"
  type        = number
  default     = 50
}

# Web Server
variable "create_web_server" {
  description = "Create web server for panel"
  type        = bool
  default     = false
}

variable "web_server_instance_type" {
  description = "Instance type for web server"
  type        = string
  default     = "t3.small" # 2 vCPU, 2GB RAM
}

variable "web_server_volume_size" {
  description = "Root volume size for web server (GB)"
  type        = number
  default     = 20
}
