###############################################################################
# DNS Module Outputs
###############################################################################

output "zone_id" {
  description = "Route53 hosted zone ID for the16oracles.io"
  value       = aws_route53_zone.the16oracles_io.zone_id
}

output "zone_name_servers" {
  description = "Name servers for the16oracles.io hosted zone"
  value       = aws_route53_zone.the16oracles_io.name_servers
}

output "acm_api_rookiecard_arn" {
  description = "ACM certificate ARN for api.rookiecard.xyz"
  value       = aws_acm_certificate.api_rookiecard_xyz.arn
}

output "acm_api_the16oracles_arn" {
  description = "ACM certificate ARN for api.the16oracles.io"
  value       = aws_acm_certificate.api_the16oracles_io.arn
}

output "acm_svcs_the16oracles_arn" {
  description = "ACM certificate ARN for svcs.the16oracles.io"
  value       = aws_acm_certificate.svcs_the16oracles_io.arn
}

output "acm_www_the16oracles_arn" {
  description = "ACM certificate ARN for www.the16oracles.io"
  value       = aws_acm_certificate.www_the16oracles_io.arn
}
