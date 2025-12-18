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

## Credenciais

### RDS MSSQL
- **Endpoint:** (gerado após apply)
- **Port:** 1433
- **Username:** `koadmin`
- **Password:** `U9UZ00OWwE89TN4b`

### EC2 Windows
- **Key Pair:** `macOS-keypair2024`
- **RDP Port:** 3389
- **Admin IP liberado:** `189.78.39.245/32`

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

## Conexão do Mac

### Azure Data Studio (MSSQL)
```
Server: <rds_endpoint>
Port: 1433
Authentication: SQL Login
User: koadmin
Password: U9UZ00OWwE89TN4b
```

### RDP (Windows Server)
```
App: Microsoft Remote Desktop
Host: <game_server_public_ip>
Port: 3389
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

## Próximos Passos

1. [ ] Aplicar Terraform (`terraform apply`)
2. [ ] Conectar RDP no Windows Server
3. [ ] Instalar Visual C++ Redistributables
4. [ ] Conectar Azure Data Studio no RDS
5. [ ] Importar databases (KNIGHT_ONLINE, ACCOUNT_DB)
6. [ ] Copiar server files e configurar .ini
7. [ ] Testar conexão do cliente

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

### RDS não conecta?
1. Verificar se IP está no Security Group
2. Verificar se RDS está `publicly_accessible = true`
3. Testar com telnet: `nc -zv <rds_endpoint> 1433`
