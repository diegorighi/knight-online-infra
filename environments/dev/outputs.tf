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
      MSSQL Port: 1433

    ${var.create_web_server ? "WEB SERVER (Linux):\n      IP: ${module.web_server[0].public_ip}\n      HTTP: 80\n      HTTPS: 443\n      SSH: 22" : "WEB SERVER: Not created"}

    CLIENT CONFIG (Ebenezer.ini):
      SERVER_IP = ${module.game_server.public_ip}

    ============================================
  EOF
}

output "rdp_connection_command" {
  description = "RDP connection info"
  value       = "Connect via RDP to: ${module.game_server.public_ip}:3389"
}
