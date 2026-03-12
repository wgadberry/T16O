###############################################################################
# Networking Module Outputs
###############################################################################

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = aws_lb.nlb_api_gateway.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID of the NLB"
  value       = aws_lb.nlb_api_gateway.zone_id
}

output "nlb_arn" {
  description = "ARN of the NLB"
  value       = aws_lb.nlb_api_gateway.arn
}
