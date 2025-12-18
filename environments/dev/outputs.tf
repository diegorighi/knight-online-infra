output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "game_server_public_ip" {
  description = "Game server public IP (use for client connection)"
  value       = module.game_server.public_ip
}

output "game_server_private_ip" {
  description = "Game server private IP"
  value       = module.game_server.private_ip
}

output "game_server_instance_id" {
  description = "Game server instance ID"
  value       = module.game_server.instance_id
}

output "web_server_public_ip" {
  description = "Web server public IP"
  value       = var.create_web_server ? module.web_server[0].public_ip : null
}

output "web_server_instance_id" {
  description = "Web server instance ID"
  value       = var.create_web_server ? module.web_server[0].instance_id : null
}

output "rds_endpoint" {
  description = "RDS MSSQL endpoint"
  value       = var.create_rds ? module.rds_mssql[0].endpoint : null
}

output "rds_address" {
  description = "RDS MSSQL hostname"
  value       = var.create_rds ? module.rds_mssql[0].address : null
}

output "connection_info" {
  description = "Connection information"
  value = <<-EOF

    ============================================
    KNIGHT ONLINE SERVER - CONNECTION INFO
    ============================================

    GAME SERVER (Windows):
      IP: ${module.game_server.public_ip}
      RDP Port: 3389
      Game Port: 15001
      Login Port: 15100

    ${var.create_rds ? "RDS MSSQL DATABASE:\n      Endpoint: ${module.rds_mssql[0].endpoint}\n      Port: 1433\n      User: ${var.rds_username}\n      Connect from Mac: Azure Data Studio" : "RDS: Not created"}

    ${var.create_web_server ? "WEB SERVER (Linux):\n      IP: ${module.web_server[0].public_ip}\n      HTTP: 80\n      HTTPS: 443\n      SSH: 22" : "WEB SERVER: Not created"}

    CLIENT CONFIG (Ebenezer.ini):
      SERVER_IP = ${module.game_server.public_ip}
      ${var.create_rds ? "DB_SERVER = ${module.rds_mssql[0].address}" : ""}

    ============================================
  EOF
}

output "rdp_connection_command" {
  description = "RDP connection info"
  value       = "Connect via RDP to: ${module.game_server.public_ip}:3389"
}

output "azure_data_studio_connection" {
  description = "Azure Data Studio connection string"
  value       = var.create_rds ? "Server: ${module.rds_mssql[0].address},1433 | User: ${var.rds_username}" : null
}
