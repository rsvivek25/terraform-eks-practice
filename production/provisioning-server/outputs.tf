output "instance_id" {
  description = "ID of the provisioning server"
  value       = aws_instance.provisioning_server.id
}

output "instance_private_ip" {
  description = "Private IP address of the provisioning server"
  value       = aws_instance.provisioning_server.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the provisioning server (if in public subnet)"
  value       = aws_instance.provisioning_server.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address of the provisioning server (if allocated)"
  value       = var.allocate_elastic_ip ? aws_eip.provisioning_server[0].public_ip : null
}

output "security_group_id" {
  description = "ID of the provisioning server security group"
  value       = aws_security_group.provisioning_server.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.provisioning_server.name
}
