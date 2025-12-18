# Security Groups for Knight Online Server

# Game Server Security Group
resource "aws_security_group" "game_server" {
  name        = "${var.project_name}-game-server-sg"
  description = "Security group for Knight Online game server"
  vpc_id      = var.vpc_id

  # Ebenezer - Main Game Server
  ingress {
    description = "Ebenezer Game Server"
    from_port   = 15001
    to_port     = 15001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Login Server
  ingress {
    description = "Login Server"
    from_port   = 15100
    to_port     = 15100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Additional game ports (some versions use these)
  ingress {
    description = "Additional Game Ports"
    from_port   = 15000
    to_port     = 15010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MSSQL - Restricted to admin IP only
  ingress {
    description = "MSSQL Database"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = var.admin_ip_cidrs
  }

  # RDP - Restricted to admin IP only
  ingress {
    description = "RDP Access"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.admin_ip_cidrs
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-game-server-sg"
  })
}

# Web Server Security Group
resource "aws_security_group" "web_server" {
  name        = "${var.project_name}-web-server-sg"
  description = "Security group for Knight Online web panel"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH - Restricted to admin IP only
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_ip_cidrs
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-web-server-sg"
  })
}

# Internal communication between game and web server
resource "aws_security_group_rule" "game_from_web" {
  type                     = "ingress"
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_server.id
  security_group_id        = aws_security_group.game_server.id
  description              = "Allow web server to connect to MSSQL"
}
