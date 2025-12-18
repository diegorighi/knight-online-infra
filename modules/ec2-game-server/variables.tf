variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Custom AMI ID (leave empty for latest Windows Server 2022)"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Existing key pair name (if not creating new)"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for new key pair"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "create_data_volume" {
  description = "Create additional EBS volume for game data"
  type        = bool
  default     = false
}

variable "data_volume_size" {
  description = "Data volume size in GB"
  type        = number
  default     = 100
}

variable "create_elastic_ip" {
  description = "Create Elastic IP for static public IP"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Custom user data script"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
