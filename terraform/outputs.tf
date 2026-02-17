output "ec2_public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.t16o_services.public_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i docker/t160_v1_services.pem ec2-user@${aws_eip.t16o_services.public_ip}"
}

output "gateway_url" {
  description = "Gateway API URL"
  value       = "http://${aws_eip.t16o_services.public_ip}:5100"
}

output "rabbitmq_url" {
  description = "RabbitMQ Management UI"
  value       = "http://${aws_eip.t16o_services.public_ip}:15692"
}
