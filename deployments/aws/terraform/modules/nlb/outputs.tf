output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.api.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.api.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID of the Network Load Balancer"
  value       = aws_lb.api.zone_id
}

output "guide_gateway_target_group_arn" {
  description = "ARN of the Guide Gateway target group"
  value       = aws_lb_target_group.guide_gateway.arn
}

output "site_api_target_group_arn" {
  description = "ARN of the Site API target group"
  value       = aws_lb_target_group.site_api.arn
}

output "cluster_apis_target_group_arn" {
  description = "ARN of the Cluster APIs target group"
  value       = aws_lb_target_group.cluster_apis.arn
}

output "guide_gateway_port" {
  description = "Port for Guide Gateway"
  value       = var.guide_gateway_port
}

output "site_api_port" {
  description = "Port for Site API"
  value       = var.site_api_port
}

output "cluster_apis_port" {
  description = "Port for Cluster APIs"
  value       = var.cluster_apis_port
}
