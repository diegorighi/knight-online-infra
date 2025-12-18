output "game_server_sg_id" {
  description = "Game server security group ID"
  value       = aws_security_group.game_server.id
}

output "web_server_sg_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web_server.id
}
