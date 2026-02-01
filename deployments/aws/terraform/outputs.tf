# =============================================================================
# API Gateway Outputs
# =============================================================================

output "api_gateway_invoke_url" {
  description = "Base URL for API Gateway stage"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_id" {
  description = "ID of the REST API"
  value       = module.api_gateway.rest_api_id
}

output "api_key_id" {
  description = "ID of the API key"
  value       = module.api_gateway.api_key_id
}

output "api_key_value" {
  description = "Value of the API key (use: terraform output -raw api_key_value)"
  value       = module.api_gateway.api_key_value
  sensitive   = true
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = module.api_gateway.stage_name
}

# =============================================================================
# Network Load Balancer Outputs
# =============================================================================

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = module.nlb.nlb_dns_name
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = module.nlb.nlb_arn
}

# =============================================================================
# VPC Link Outputs
# =============================================================================

output "vpc_link_id" {
  description = "ID of the VPC Link"
  value       = module.vpc_link.vpc_link_id
}

# =============================================================================
# CloudWatch Outputs
# =============================================================================

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for API Gateway"
  value       = module.api_gateway.cloudwatch_log_group_name
}

# =============================================================================
# Useful Commands
# =============================================================================

output "test_commands" {
  description = "Example commands to test the API"
  value = <<-EOT
    # Get the API key value:
    terraform output -raw api_key_value

    # Test health endpoint:
    curl -H "x-api-key: $(terraform output -raw api_key_value)" ${module.api_gateway.invoke_url}guide/health

    # Test trigger endpoint:
    curl -X POST -H "x-api-key: $(terraform output -raw api_key_value)" \
      -H "Content-Type: application/json" \
      -d '{"address": "test"}' \
      ${module.api_gateway.invoke_url}guide/trigger/producer

    # Test site API:
    curl -H "x-api-key: $(terraform output -raw api_key_value)" \
      ${module.api_gateway.invoke_url}site/owner/0x123...
  EOT
}
