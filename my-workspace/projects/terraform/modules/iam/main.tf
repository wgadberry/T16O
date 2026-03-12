###############################################################################
# IAM Users
###############################################################################

resource "aws_iam_user" "jhertz" {
  name = "jhertz"
}

resource "aws_iam_user" "t16o_deploy" {
  name = "t16o-deploy"
}

resource "aws_iam_user" "wgadberry" {
  name = "wgadberry"
}

###############################################################################
# IAM Roles
###############################################################################

resource "aws_iam_role" "ec2_launch_wizard" {
  name = "AmazonEC2RoleForLaunchWizard"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # TODO: Attach managed policies after import
}

resource "aws_iam_role" "redshift_commands_access_20250611" {
  name = "AmazonRedshift-CommandsAccessRole-20250611T063358"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "redshift_commands_access_20251020" {
  name = "AmazonRedshift-CommandsAccessRole-20251020T232337"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

###############################################################################
# Customer Managed Policies
###############################################################################

resource "aws_iam_policy" "billing_admin_access" {
  name        = "BillingAdminAccess"
  description = "Billing admin access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "cur:*",
          "purchase-orders:*",
          "billing:*"
        ]
        Resource = "*"
      }
    ]
  })
  # TODO: Verify actual policy document after import
}

resource "aws_iam_policy" "redshift_commands_access_20250611" {
  name        = "AmazonRedshift-CommandsAccessPolicy-20250611T063358"
  description = "Redshift commands access policy (2025-06-11)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
  # TODO: Verify actual policy document after import
}

resource "aws_iam_policy" "redshift_commands_access_20251020" {
  name        = "AmazonRedshift-CommandsAccessPolicy-20251020T232337"
  description = "Redshift commands access policy (2025-10-20)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
  # TODO: Verify actual policy document after import
}

###############################################################################
# Role-Policy Attachments
# TODO: Add aws_iam_role_policy_attachment resources after import
###############################################################################

resource "aws_iam_role_policy_attachment" "redshift_20250611_policy" {
  role       = aws_iam_role.redshift_commands_access_20250611.name
  policy_arn = aws_iam_policy.redshift_commands_access_20250611.arn
}

resource "aws_iam_role_policy_attachment" "redshift_20251020_policy" {
  role       = aws_iam_role.redshift_commands_access_20251020.name
  policy_arn = aws_iam_policy.redshift_commands_access_20251020.arn
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_enhanced" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
