###############################################################################
# Root Outputs
###############################################################################

# VPC
output "vpc_id" {
  description = "Default VPC ID"
  value       = module.vpc.vpc_id
}

# EC2 Instances
output "velintra_os_instance_id" {
  description = "Instance ID for velintraOS"
  value       = module.compute.velintra_os_instance_id
}

output "velintra_os_private_ip" {
  description = "Private IP of velintraOS"
  value       = module.compute.velintra_os_private_ip
}

output "svcs_instance_id" {
  description = "Instance ID for svcs.the16oracles.io"
  value       = module.compute.svcs_instance_id
}

output "svcs_private_ip" {
  description = "Private IP of svcs.the16oracles.io"
  value       = module.compute.svcs_private_ip
}

output "svcs_elastic_ip" {
  description = "Elastic IP for svcs.the16oracles.io"
  value       = module.compute.svcs_elastic_ip
}

# NLB
output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = module.networking.nlb_dns_name
}

output "nlb_arn" {
  description = "ARN of the NLB"
  value       = module.networking.nlb_arn
}

# API Gateway
output "api_gateway_svcs_url" {
  description = "Invoke URL for svcs.the16oracles.io API Gateway (prod stage)"
  value       = module.api_gateway.svcs_invoke_url
}

output "api_gateway_api_url" {
  description = "Invoke URL for api.the16oracles.io API Gateway (prod stage)"
  value       = module.api_gateway.api_invoke_url
}

output "api_gateway_www_id" {
  description = "REST API ID for www.the16oracles.io (no stage deployed)"
  value       = module.api_gateway.www_rest_api_id
}

# Route53
output "route53_zone_id" {
  description = "Route53 hosted zone ID for the16oracles.io"
  value       = module.dns.zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers for the16oracles.io hosted zone"
  value       = module.dns.zone_name_servers
}

# S3
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.bucket_arn
}
