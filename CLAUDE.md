# Knight Online Private Server - Infrastructure

## Projeto
Servidor privado de Knight Online **v1299** hospedado na AWS com infraestrutura gerenciada via Terraform.

**Versão:** 1299 (2009-2010) - El Morad Castle, Luferson Castle, Ronark Land

## Repositórios

### Infraestrutura (Terraform)
- **GitHub:** https://github.com/diegorighi/knight-online-infra
- **Local:** `/Users/diegorighi/Desenvolvimento/knight-online-infra`

### Server Files (OpenKO v1299)
- **GitHub:** https://github.com/Open-KO/KnightOnline
- **Local:** `/Users/diegorighi/Desenvolvimento/knight-online/server-files-1299`
- **Conteúdo:** AIServer, Aujard, Ebenezer, Client, Tools

### Database Scripts
- **GitHub:** https://github.com/ko4life-net/ko-db
- **Local:** `/Users/diegorighi/Desenvolvimento/knight-online/database`
- **Conteúdo:** Schema SQL, Stored Procedures, Data inserts

## AWS Account
- **Account ID:** 530184476864
- **Profile:** `default` (conta pessoal - NÃO usar `rio-admin` que é da empresa)
- **Região:** `sa-east-1` (São Paulo)

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS VPC (sa-east-1)                          │
│                                                                  │
│  ┌──────────────────────┐    ┌──────────────────────┐          │
│  │   EC2 Game Server    │    │     RDS MSSQL        │          │
│  │   Windows Server     │───▶│   SQL Server Express │          │
│  │   t2.micro (Free)    │    │   db.t3.micro        │          │
│  │                      │    │                      │          │
│  │   - Ebenezer.exe     │    │   - KNIGHT_ONLINE    │          │
│  │   - AIServer.exe     │    │   - ACCOUNT_DB       │          │
│  │   - LoginServer.exe  │    │                      │          │
│  │   - Aujard.exe       │    │                      │          │
│  │                      │    │                      │          │
│  │   Ports: 15001,15100 │    │   Port: 1433         │          │
│  │          3389 (RDP)  │    │                      │          │
│  └──────────────────────┘    └──────────────────────┘          │
│                                       ▲                         │
│                                       │                         │
└───────────────────────────────────────┼─────────────────────────┘
                                        │
                              ┌─────────┴─────────┐
                              │  macOS M2 (Admin) │
                              │  Azure Data Studio│
                              │  IP: 189.78.39.245│
                              └───────────────────┘
```

## Recursos Terraform

### Ambiente DEV (`environments/dev/`)

| Recurso | Tipo | Custo |
|---------|------|-------|
| VPC | 10.0.0.0/16 | $0 |
| Subnets | 2 públicas | $0 |
| EC2 | t2.micro Windows | $0 (Free Tier) |
| EBS | 30GB gp3 | $0 (Free Tier) |
| Elastic IP | 1 | $0 |
| RDS MSSQL | db.t3.micro | ~$15/mês |
| RDS Storage | 20GB | ~$2/mês |
| **Total** | | **~$17/mês** |

### Módulos

```
modules/
├── vpc/                 # VPC, subnets, internet gateway, route tables
├── security-groups/     # Firewall rules (portas KO: 15001, 15100, 1433, 3389)
├── ec2-game-server/     # Windows Server para game server
├── ec2-web-server/      # Linux para painel web (opcional)
└── rds-mssql/           # RDS SQL Server Express
```

## Infraestrutura Provisionada (2024-12-21)

### Game Server (EC2 Windows)
| Atributo | Valor |
|----------|-------|
| Instance ID | `i-071d5ef7118747821` |
| IP Publico (Elastic IP) | `56.125.141.150` |
| IP Privado | `10.0.1.154` |
| Tipo | `t2.micro` (Free Tier) |
| AMI | Windows Server 2022 |
| Key Pair | `macOS-keypair2024` |

### RDS MSSQL
| Atributo | Valor |
|----------|-------|
| Endpoint | `knight-online-dev-mssql.cneocl9ggplh.sa-east-1.rds.amazonaws.com` |
| Porta | `1433` |
| Usuario | `koadmin` |
| Senha | `U9UZ00OWwE89TN4b` |
| Tipo | `db.t3.micro` |
| Engine | SQL Server Express 15.00 |
| Storage | 20GB (max 50GB autoscaling) |

### VPC e Rede
| Atributo | Valor |
|----------|-------|
| VPC ID | `vpc-0e6d1664229a0a59b` |
| CIDR | `10.0.0.0/16` |
| Subnet 1 | `subnet-0965f63fbeed507d9` (sa-east-1a) |
| Subnet 2 | `subnet-0e2745b8329180cdb` (sa-east-1b) |
| Internet Gateway | `igw-0edb482b65c9baaac` |

### Security Groups
| SG | ID | Portas |
|----|----|----|
| Game Server | `sg-03596973fc345a5e7` | 15001, 15100, 3389, 1433 |
| Web Server | `sg-02adf03e87bf8f301` | 80, 443, 22 |
| RDS | `sg-0bafd08d51af350ae` | 1433 |

### Admin Access
- **IP liberado:** `189.78.39.245/32`

## Portas Knight Online

| Porta | Serviço | Acesso |
|-------|---------|--------|
| 15001 | Ebenezer (Game) | Público |
| 15100 | Login Server | Público |
| 1433 | MSSQL | Admin IP + EC2 |
| 3389 | RDP | Admin IP |

## Comandos Terraform

```bash
cd /Users/diegorighi/Desenvolvimento/knight-online-infra/environments/dev

# Inicializar
terraform init

# Ver plano
terraform plan

# Aplicar
terraform apply

# Destruir
terraform destroy

# Ver outputs
terraform output
terraform output connection_info
```

## Conexao do Mac

### Azure Data Studio (MSSQL)
```
Server: knight-online-dev-mssql.cneocl9ggplh.sa-east-1.rds.amazonaws.com,1433
Authentication: SQL Login
User: koadmin
Password: U9UZ00OWwE89TN4b
```

### RDP (Windows Server)
```
App: Microsoft Remote Desktop
Host: 56.125.141.150
Port: 3389
```

### Configuracao Server Files (Server.ini / Ebenezer.ini)
```ini
SERVER_IP = 56.125.141.150
DB_SERVER = knight-online-dev-mssql.cneocl9ggplh.sa-east-1.rds.amazonaws.com
DB_PORT = 1433
DB_USER = koadmin
DB_PASS = U9UZ00OWwE89TN4b
```

## Proteção DDoS

### Atual (Gratuito)
- AWS Shield Standard (automático)
- Security Groups restritivos
- VPC isolada

### Futuro (se necessário)
- AWS Global Accelerator (~$50/mês)
- Cloudflare Spectrum (~$100/mês)

## Decisões Técnicas

### Por que NÃO usar ECS/ECR?
- Server files são executáveis Windows nativos (.exe)
- Não são containerizáveis
- ECS só faria sentido para o painel web

### Por que NÃO usar Cognito?
- KO usa sistema próprio de auth (LoginServer + ACCOUNT_DB)
- Cognito seria overengineering para servidor privado

### Por que RDS ao invés de MSSQL no EC2?
- Ambiente macOS M2 não roda MSSQL localmente
- RDS permite gerenciar banco do Mac via Azure Data Studio
- Backups automáticos
- Custo aceitável (~$15/mês)

## Proximos Passos

1. [x] Aplicar Terraform (`terraform apply`) - FEITO 2024-12-21
2. [ ] Conectar RDP no Windows Server (56.125.141.150:3389)
3. [ ] Instalar Visual C++ Redistributables (script ja incluso no user_data)
4. [ ] Conectar Azure Data Studio no RDS
5. [ ] Importar databases (KNIGHT_ONLINE, ACCOUNT_DB) do repo ko-db
6. [ ] Copiar server files e configurar .ini com IPs acima
7. [ ] Testar conexao do cliente

## Arquivos Importantes

- `terraform.tfvars` - Variáveis com credenciais (não commitar!)
- `.terraform.lock.hcl` - Lock de providers
- `terraform.tfstate` - Estado da infra (não commitar!)

## Troubleshooting

### IP mudou?
```bash
# Pegar novo IP
curl ifconfig.me

# Atualizar terraform.tfvars
admin_ip_cidrs = ["NOVO.IP.AQUI/32"]

# Aplicar mudança
terraform apply
```

### RDS nao conecta?
1. Verificar se IP esta no Security Group
2. Verificar se RDS esta `publicly_accessible = true`
3. Testar com: `nc -zv knight-online-dev-mssql.cneocl9ggplh.sa-east-1.rds.amazonaws.com 1433`

### Obter senha do Windows (RDP)
```bash
aws ec2 get-password-data --instance-id i-071d5ef7118747821 --priv-launch-key ~/.ssh/macOS-keypair2024.pem --query PasswordData --output text
```
