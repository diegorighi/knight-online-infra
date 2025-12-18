output "instance_id" {
  description = "Game server instance ID"
  value       = aws_instance.game_server.id
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.game_server.private_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = var.create_elastic_ip ? aws_eip.game_server[0].public_ip : aws_instance.game_server.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.game_server.public_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_elastic_ip ? aws_eip.game_server[0].public_ip : null
}

output "password_data" {
  description = "Encrypted password data (use with key pair to decrypt)"
  value       = aws_instance.game_server.password_data
  sensitive   = true
}
