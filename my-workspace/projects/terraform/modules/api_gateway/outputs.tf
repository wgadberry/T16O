###############################################################################
# API Gateway Module Outputs
###############################################################################

output "svcs_invoke_url" {
  description = "Invoke URL for svcs.the16oracles.io API Gateway (prod stage)"
  value       = aws_api_gateway_stage.svcs_the16oracles_io_prod.invoke_url
}

output "api_invoke_url" {
  description = "Invoke URL for api.the16oracles.io API Gateway (prod stage)"
  value       = aws_api_gateway_stage.api_the16oracles_io_prod.invoke_url
}

output "www_rest_api_id" {
  description = "REST API ID for www.the16oracles.io (no stage deployed)"
  value       = aws_api_gateway_rest_api.www_the16oracles_io.id
}
