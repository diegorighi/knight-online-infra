output "instance_id" {
  description = "Web server instance ID"
  value       = aws_instance.web_server.id
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.web_server.private_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = var.create_elastic_ip ? aws_eip.web_server[0].public_ip : aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.web_server.public_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.create_elastic_ip ? aws_eip.web_server[0].public_ip : null
}
