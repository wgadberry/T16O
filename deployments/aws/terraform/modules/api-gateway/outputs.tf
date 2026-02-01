output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_arn" {
  description = "ARN of the REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.main.stage_name
}

output "invoke_url" {
  description = "Base URL for API Gateway stage"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_key_id" {
  description = "ID of the API key"
  value       = aws_api_gateway_api_key.main.id
}

output "api_key_value" {
  description = "Value of the API key"
  value       = aws_api_gateway_api_key.main.value
  sensitive   = true
}

output "usage_plan_id" {
  description = "ID of the usage plan"
  value       = aws_api_gateway_usage_plan.main.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway.name
}

output "execution_arn" {
  description = "Execution ARN prefix for the API Gateway stage"
  value       = aws_api_gateway_stage.main.execution_arn
}
