# Knight Online Private Server - AWS Infrastructure

Terraform infrastructure for deploying a Knight Online private server on AWS.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS VPC                                  │
│                                                                  │
│  ┌──────────────────────┐    ┌──────────────────────┐          │
│  │   Game Server (EC2)  │    │   Web Server (EC2)   │          │
│  │   Windows Server     │    │   Amazon Linux       │          │
│  │                      │    │                      │          │
│  │   - Ebenezer.exe     │◄───│   - Nginx            │          │
│  │   - AIServer.exe     │    │   - PHP/Node.js      │          │
│  │   - LoginServer.exe  │    │   - KOPanel          │          │
│  │   - Aujard.exe       │    │                      │          │
│  │   - MSSQL Server     │    │                      │          │
│  │                      │    │                      │          │
│  │   Ports:             │    │   Ports:             │          │
│  │   - 15001 (Game)     │    │   - 80/443 (HTTP/S)  │          │
│  │   - 15100 (Login)    │    │   - 22 (SSH)         │          │
│  │   - 1433 (MSSQL)     │    │                      │          │
│  │   - 3389 (RDP)       │    │                      │          │
│  └──────────────────────┘    └──────────────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                        ┌───────────┐
                        │  Players  │
                        │ (Client)  │
                        └───────────┘
```

## Structure

```
.
├── modules/
│   ├── vpc/                 # VPC, subnets, routing
│   ├── security-groups/     # Firewall rules
│   ├── ec2-game-server/     # Windows Server for game
│   └── ec2-web-server/      # Linux for web panel
├── environments/
│   ├── dev/                 # Development environment
│   └── prod/                # Production environment
└── README.md
```

## Quick Start

### Prerequisites

- [Terraform](https://terraform.io) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS account with appropriate permissions

### 1. Clone and Configure

```bash
git clone https://github.com/diegorighi/knight-online-infra.git
cd knight-online-infra/environments/dev

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars

```hcl
# Get your IP: curl ifconfig.me
admin_ip_cidrs = ["YOUR.IP.ADDRESS/32"]

# Use existing key pair or create new one
existing_key_name = "your-key-name"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Get Connection Info

```bash
terraform output connection_info
```

## Environments

| Environment | Instance Type | Monthly Cost (est.) |
|-------------|---------------|---------------------|
| Dev | t2.micro (1GB) | **FREE** (first 12 months) |
| Prod | t3.large (8GB) | ~$75-90 |

### AWS Free Tier (Dev Environment)

- **EC2 t2.micro**: 750 hours/month FREE (first 12 months)
- **EBS Storage**: 30GB FREE (first 12 months)
- **Elastic IP**: FREE when attached to running instance
- **Data Transfer**: 15GB/month outbound FREE

> **Note**: t2.micro (1GB RAM) is limited for Knight Online. Good for testing configs, but gameplay may be slow with multiple players.

## Security Notes

- **MSSQL (1433)** and **RDP (3389)** are restricted to `admin_ip_cidrs`
- Always update your IP in `terraform.tfvars` before accessing
- Use strong passwords for Windows and MSSQL
- Enable Windows Firewall after initial setup

## Post-Deployment Setup

### On Game Server (Windows)

1. Connect via RDP
2. Install MSSQL Server 2014 Express
3. Install Visual C++ Redistributables
4. Import game databases
5. Copy server files and configure .ini files
6. Start server executables

### On Web Server (Linux)

1. Connect via SSH
2. Deploy KOPanel or custom panel
3. Configure MSSQL connection
4. Set up SSL certificate (Let's Encrypt)

## Useful Commands

```bash
# Destroy infrastructure
terraform destroy

# Update after changes
terraform plan
terraform apply

# Get outputs
terraform output game_server_public_ip
terraform output web_server_public_ip
```

## Estimated Costs (USD/month)

| Resource | Dev (Free Tier) | Prod |
|----------|-----------------|------|
| EC2 Game Server | **$0** | $60 |
| EC2 Web Server | - | $15 |
| EBS Storage (30GB) | **$0** | $20 |
| Elastic IP | **$0** | $8 |
| **Total** | **$0** | **~$103** |

> Free Tier valid for first 12 months of AWS account. After that, Dev costs ~$15/month.

## License

This project is for educational purposes only. Running private game servers may violate the original game's Terms of Service.
