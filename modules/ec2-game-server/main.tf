# EC2 Game Server Module - Windows Server for Knight Online

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach SSM policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.project_name}-ssm-profile"
  role  = aws_iam_role.ssm_role[0].name

  tags = var.tags
}

# Get latest Windows Server 2022 AMI
data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair for RDP access
resource "aws_key_pair" "game_server" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.project_name}-game-server-key"
  public_key = var.public_key

  tags = var.tags
}

# EBS volume for game data
resource "aws_ebs_volume" "game_data" {
  count             = var.create_data_volume ? 1 : 0
  availability_zone = var.availability_zone
  size              = var.data_volume_size
  type              = "gp3"
  encrypted         = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-game-data"
  })
}

# EC2 Instance - Game Server
resource "aws_instance" "game_server" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.windows_2022.id
  instance_type          = var.instance_type
  key_name               = var.create_key_pair ? aws_key_pair.game_server[0].key_name : var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  availability_zone      = var.availability_zone
  iam_instance_profile   = var.enable_ssm ? aws_iam_instance_profile.ssm_profile[0].name : null

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false

    tags = merge(var.tags, {
      Name = "${var.project_name}-game-server-root"
    })
  }

  # User data script to configure Windows
  user_data = var.user_data != "" ? var.user_data : <<-EOF
    <powershell>
    # Enable RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Set timezone
    Set-TimeZone -Id "E. South America Standard Time"

    # Install .NET Framework 3.5
    Install-WindowsFeature Net-Framework-Core

    # Create game server directory
    New-Item -ItemType Directory -Force -Path "C:\KnightOnline"
    New-Item -ItemType Directory -Force -Path "C:\KnightOnline\Server"
    New-Item -ItemType Directory -Force -Path "C:\KnightOnline\Database"
    New-Item -ItemType Directory -Force -Path "C:\KnightOnline\Backups"

    # Download Visual C++ Redistributables
    $vcRedistUrls = @(
      "https://aka.ms/vs/17/release/vc_redist.x64.exe",
      "https://aka.ms/vs/17/release/vc_redist.x86.exe"
    )

    foreach ($url in $vcRedistUrls) {
      $filename = $url.Split('/')[-1]
      $outPath = "C:\KnightOnline\$filename"
      Invoke-WebRequest -Uri $url -OutFile $outPath
    }

    # Set Windows Firewall rules for Knight Online
    New-NetFirewallRule -DisplayName "Knight Online - Ebenezer" -Direction Inbound -Protocol TCP -LocalPort 15001 -Action Allow
    New-NetFirewallRule -DisplayName "Knight Online - Login Server" -Direction Inbound -Protocol TCP -LocalPort 15100 -Action Allow
    New-NetFirewallRule -DisplayName "Knight Online - Game Ports" -Direction Inbound -Protocol TCP -LocalPort 15000-15010 -Action Allow
    New-NetFirewallRule -DisplayName "MSSQL" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow

    # Log completion
    "Setup completed at $(Get-Date)" | Out-File "C:\KnightOnline\setup_log.txt"
    </powershell>
  EOF

  tags = merge(var.tags, {
    Name = "${var.project_name}-game-server"
    Role = "GameServer"
  })

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# Attach data volume
resource "aws_volume_attachment" "game_data" {
  count       = var.create_data_volume ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.game_data[0].id
  instance_id = aws_instance.game_server.id
}

# Elastic IP for static public IP
resource "aws_eip" "game_server" {
  count    = var.create_elastic_ip ? 1 : 0
  instance = aws_instance.game_server.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-game-server-eip"
  })
}
