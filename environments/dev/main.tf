# Knight Online Private Server - Development Environment

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use S3 backend for state management
  # backend "s3" {
  #   bucket         = "knight-online-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region  = var.aws_region
  profile = "default" # Explicitly use personal account, not rio-admin (company)

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  admin_ip_cidrs = var.admin_ip_cidrs

  tags = local.common_tags
}

# Game Server Module (Windows)
module "game_server" {
  source = "../../modules/ec2-game-server"

  project_name       = var.project_name
  instance_type      = var.game_server_instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  availability_zone  = data.aws_availability_zones.available.names[0]
  security_group_ids = [module.security_groups.game_server_sg_id]
  root_volume_size   = var.game_server_volume_size
  create_elastic_ip  = true
  create_key_pair    = var.create_key_pair
  public_key         = var.public_key
  key_name           = var.existing_key_name

  tags = local.common_tags
}

# Web Server Module (Linux) - Optional
module "web_server" {
  source = "../../modules/ec2-web-server"
  count  = var.create_web_server ? 1 : 0

  project_name       = var.project_name
  instance_type      = var.web_server_instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  availability_zone  = data.aws_availability_zones.available.names[0]
  security_group_ids = [module.security_groups.web_server_sg_id]
  root_volume_size   = var.web_server_volume_size
  create_elastic_ip  = true
  create_key_pair    = var.create_key_pair
  public_key         = var.public_key
  key_name           = var.existing_key_name

  tags = local.common_tags
}

# RDS MSSQL Module - Knight Online Database
module "rds_mssql" {
  source = "../../modules/rds-mssql"
  count  = var.create_rds ? 1 : 0

  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  allowed_security_group_ids = [module.security_groups.game_server_sg_id]
  admin_ip_cidrs             = var.admin_ip_cidrs
  instance_class             = var.rds_instance_class
  allocated_storage          = var.rds_allocated_storage
  db_username                = var.rds_username
  db_password                = var.rds_password
  publicly_accessible        = true # For Mac access via Azure Data Studio
  skip_final_snapshot        = true # Dev environment

  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}
