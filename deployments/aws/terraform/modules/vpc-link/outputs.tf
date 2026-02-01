output "vpc_link_id" {
  description = "ID of the VPC Link"
  value       = aws_api_gateway_vpc_link.main.id
}

output "vpc_link_arn" {
  description = "ARN of the VPC Link"
  value       = aws_api_gateway_vpc_link.main.arn
}

output "security_group_id" {
  description = "ID of the VPC Link security group"
  value       = aws_security_group.vpc_link.id
}
