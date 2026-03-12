###############################################################################
# Monitoring Module Outputs
###############################################################################

output "dynamodb_imports_log_group_arn" {
  description = "ARN of the /aws-dynamodb/imports log group"
  value       = aws_cloudwatch_log_group.dynamodb_imports.arn
}

output "rds_os_metrics_log_group_arn" {
  description = "ARN of the RDSOSMetrics log group"
  value       = aws_cloudwatch_log_group.rds_os_metrics.arn
}
