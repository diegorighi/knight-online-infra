# EC2 Web Server Module - Linux for Knight Online Panel

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair for SSH access
resource "aws_key_pair" "web_server" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.project_name}-web-server-key"
  public_key = var.public_key

  tags = var.tags
}

# EC2 Instance - Web Server
resource "aws_instance" "web_server" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.create_key_pair ? aws_key_pair.web_server[0].key_name : var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  availability_zone      = var.availability_zone

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false

    tags = merge(var.tags, {
      Name = "${var.project_name}-web-server-root"
    })
  }

  # User data script to configure Linux
  user_data = var.user_data != "" ? var.user_data : <<-EOF
    #!/bin/bash
    set -e

    # Update system
    dnf update -y

    # Install required packages
    dnf install -y nginx nodejs npm git docker

    # Install PHP 8.2 (for KOPanel compatibility)
    dnf install -y php8.2 php8.2-fpm php8.2-mysqlnd php8.2-pdo php8.2-mbstring php8.2-xml php8.2-curl

    # Install MSSQL driver for PHP
    curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/mssql-release.repo
    ACCEPT_EULA=Y dnf install -y msodbcsql18 mssql-tools18 unixODBC-devel
    dnf install -y php8.2-sqlsrv php8.2-pdo_sqlsrv || true

    # Start services
    systemctl enable nginx php-fpm docker
    systemctl start nginx php-fpm docker

    # Create web directory
    mkdir -p /var/www/knight-online
    chown -R nginx:nginx /var/www/knight-online

    # Create Nginx config
    cat > /etc/nginx/conf.d/knight-online.conf << 'NGINX'
    server {
        listen 80;
        server_name _;
        root /var/www/knight-online/public;
        index index.php index.html;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            fastcgi_pass unix:/run/php-fpm/www.sock;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        location ~ /\.ht {
            deny all;
        }
    }
    NGINX

    systemctl restart nginx

    # Log completion
    echo "Setup completed at $(date)" >> /var/log/knight-online-setup.log
  EOF

  tags = merge(var.tags, {
    Name = "${var.project_name}-web-server"
    Role = "WebServer"
  })

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# Elastic IP for static public IP
resource "aws_eip" "web_server" {
  count    = var.create_elastic_ip ? 1 : 0
  instance = aws_instance.web_server.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-web-server-eip"
  })
}
