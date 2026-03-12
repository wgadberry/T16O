###############################################################################
# IAM Module Outputs
###############################################################################

output "ec2_launch_wizard_role_arn" {
  description = "ARN of the EC2 launch wizard role"
  value       = aws_iam_role.ec2_launch_wizard.arn
}

output "rds_monitoring_role_arn" {
  description = "ARN of the RDS monitoring role"
  value       = aws_iam_role.rds_monitoring_role.arn
}

output "billing_admin_policy_arn" {
  description = "ARN of the billing admin access policy"
  value       = aws_iam_policy.billing_admin_access.arn
}
