###############################################################################
# CloudWatch Log Groups
###############################################################################

resource "aws_cloudwatch_log_group" "dynamodb_imports" {
  name              = "/aws-dynamodb/imports"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "rds_os_metrics" {
  name              = "RDSOSMetrics"
  retention_in_days = 30
}

###############################################################################
# Secrets Manager
#
# NOTE: There are 10 Redshift Query Editor auto-generated secrets in this
# account. These are created and managed by the AWS Redshift Query Editor
# service automatically and are NOT included in Terraform state.
#
# Secret name pattern: redshift!*
#
# These secrets are tied to Redshift Query Editor sessions and should not
# be imported or managed by Terraform as they are ephemeral service-managed
# resources.
###############################################################################
