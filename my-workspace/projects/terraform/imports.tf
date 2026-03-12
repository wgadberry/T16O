###############################################################################
# Terraform Import Blocks (Terraform 1.5+ syntax)
#
# Usage: Run `terraform plan` to generate the import operations, then
#        `terraform apply` to import all resources into state.
#
# After import, run `terraform plan` again to identify any drift between
# the HCL definitions and actual AWS state, then update the .tf files
# accordingly.
###############################################################################

###############################################################################
# VPC
###############################################################################

import {
  to = module.vpc.aws_default_vpc.default
  id = "vpc-03cdd15d62aacb9ac"
}

import {
  to = module.vpc.aws_default_subnet.us_east_1a
  id = "subnet-0a" # TODO: Replace with actual subnet ID for us-east-1a
}

import {
  to = module.vpc.aws_default_subnet.us_east_1b
  id = "subnet-0b" # TODO: Replace with actual subnet ID for us-east-1b
}

import {
  to = module.vpc.aws_default_subnet.us_east_1c
  id = "subnet-0c" # TODO: Replace with actual subnet ID for us-east-1c
}

import {
  to = module.vpc.aws_default_subnet.us_east_1d
  id = "subnet-0d" # TODO: Replace with actual subnet ID for us-east-1d
}

import {
  to = module.vpc.aws_default_subnet.us_east_1e
  id = "subnet-0e" # TODO: Replace with actual subnet ID for us-east-1e
}

import {
  to = module.vpc.aws_default_subnet.us_east_1f
  id = "subnet-0f" # TODO: Replace with actual subnet ID for us-east-1f
}

import {
  to = module.vpc.aws_internet_gateway.default
  id = "igw-0ef4195850ef40b12"
}

import {
  to = module.vpc.aws_default_route_table.default
  id = "rtb-0a3c8feac5883d754"
}

###############################################################################
# Security Groups
###############################################################################

import {
  to = module.vpc.aws_default_security_group.default
  id = "sg-default" # TODO: Replace with actual default SG ID
}

import {
  to = module.vpc.aws_security_group.sg_velintra
  id = "sg-velintra" # TODO: Replace with actual SG ID
}

import {
  to = module.vpc.aws_security_group.t16o_v1_services_sg
  id = "sg-t16o-v1-services" # TODO: Replace with actual SG ID
}

import {
  to = module.vpc.aws_security_group.launch_wizard_2
  id = "sg-launch-wizard-2" # TODO: Replace with actual SG ID
}

import {
  to = module.vpc.aws_security_group.launch_wizard_1
  id = "sg-launch-wizard-1" # TODO: Replace with actual SG ID
}

###############################################################################
# Key Pairs
###############################################################################

import {
  to = module.compute.aws_key_pair.t160_v1_services
  id = "t160_v1_services"
}

import {
  to = module.compute.aws_key_pair.kp_node_win_svc_16o
  id = "kp-nodeWinSvc16o"
}

import {
  to = module.compute.aws_key_pair.kp_velintra
  id = "kp-velintra"
}

import {
  to = module.compute.aws_key_pair.t160_core_winsrv_01
  id = "t160_core_winsrv_01"
}

import {
  to = module.compute.aws_key_pair.node_win_svc_16o
  id = "node-win-svc-16o"
}

import {
  to = module.compute.aws_key_pair.t16o_core_lnxsrv_01
  id = "t16o_core_lnxsrv_01"
}

###############################################################################
# EC2 Instances
###############################################################################

import {
  to = module.compute.aws_instance.velintra_os
  id = "i-02dee9da1cdae26a1"
}

import {
  to = module.compute.aws_instance.svcs_the16oracles_io
  id = "i-08876487ad5fdf4b7"
}

###############################################################################
# Elastic IP
###############################################################################

import {
  to = module.compute.aws_eip.svcs_the16oracles_io
  id = "eipalloc-06cd32d9cb8904b4f"
}

import {
  to = module.compute.aws_eip_association.svcs_the16oracles_io
  id = "eipassoc-placeholder" # TODO: Replace with actual EIP association ID
}

###############################################################################
# EBS Volumes
###############################################################################

import {
  to = module.compute.aws_ebs_volume.velintra_os_data
  id = "vol-placeholder-velintra" # TODO: Replace with actual volume ID
}

import {
  to = module.compute.aws_ebs_volume.svcs_the16oracles_io_data
  id = "vol-placeholder-svcs" # TODO: Replace with actual volume ID
}

###############################################################################
# S3
###############################################################################

import {
  to = module.storage.aws_s3_bucket.bkt_16o
  id = "bkt-16o"
}

###############################################################################
# API Gateway REST APIs
###############################################################################

import {
  to = module.api_gateway.aws_api_gateway_rest_api.svcs_the16oracles_io
  id = "5bogz4ea3l"
}

import {
  to = module.api_gateway.aws_api_gateway_rest_api.api_the16oracles_io
  id = "8pl0vvijy3"
}

import {
  to = module.api_gateway.aws_api_gateway_rest_api.www_the16oracles_io
  id = "p9czn68t0h"
}

import {
  to = module.api_gateway.aws_api_gateway_stage.svcs_the16oracles_io_prod
  id = "5bogz4ea3l/prod"
}

import {
  to = module.api_gateway.aws_api_gateway_stage.api_the16oracles_io_prod
  id = "8pl0vvijy3/prod"
}

# NOTE: aws_api_gateway_deployment imports require deployment IDs
# which change on each deploy. These will be captured during import.
import {
  to = module.api_gateway.aws_api_gateway_deployment.svcs_the16oracles_io_prod
  id = "5bogz4ea3l/placeholder" # TODO: Replace with actual deployment ID
}

import {
  to = module.api_gateway.aws_api_gateway_deployment.api_the16oracles_io_prod
  id = "8pl0vvijy3/placeholder" # TODO: Replace with actual deployment ID
}

###############################################################################
# Load Balancer
###############################################################################

import {
  to = module.networking.aws_lb.nlb_api_gateway
  id = "arn:aws:elasticloadbalancing:us-east-1:900734131342:loadbalancer/net/nlb-api-gateway/placeholder" # TODO: Replace with actual ARN
}

import {
  to = module.networking.aws_lb_target_group.tg_api_gateway
  id = "arn:aws:elasticloadbalancing:us-east-1:900734131342:targetgroup/tg-api-gateway/placeholder" # TODO: Replace with actual ARN
}

import {
  to = module.networking.aws_lb_target_group.tg_t16o_api
  id = "arn:aws:elasticloadbalancing:us-east-1:900734131342:targetgroup/tg-t16o-api/placeholder" # TODO: Replace with actual ARN
}

###############################################################################
# Route53
###############################################################################

import {
  to = module.dns.aws_route53_zone.the16oracles_io
  id = "Z06257209LDGRSWS1EDX"
}

import {
  to = module.dns.aws_route53_record.the16oracles_io_ns
  id = "Z06257209LDGRSWS1EDX_the16oracles.io_NS"
}

import {
  to = module.dns.aws_route53_record.the16oracles_io_soa
  id = "Z06257209LDGRSWS1EDX_the16oracles.io_SOA"
}

import {
  to = module.dns.aws_route53_record.dmarc_txt
  id = "Z06257209LDGRSWS1EDX__dmarc.the16oracles.io_TXT"
}

import {
  to = module.dns.aws_route53_record.domainconnect_cname
  id = "Z06257209LDGRSWS1EDX__domainconnect.the16oracles.io_CNAME"
}

import {
  to = module.dns.aws_route53_record.api_a
  id = "Z06257209LDGRSWS1EDX_api.the16oracles.io_A"
}

import {
  to = module.dns.aws_route53_record.api_acm_validation
  id = "Z06257209LDGRSWS1EDX__placeholder.api.the16oracles.io_CNAME" # TODO: Replace with actual ACM validation record name
}

import {
  to = module.dns.aws_route53_record.svcs_a
  id = "Z06257209LDGRSWS1EDX_svcs.the16oracles.io_A"
}

###############################################################################
# ACM Certificates
###############################################################################

import {
  to = module.dns.aws_acm_certificate.api_rookiecard_xyz
  id = "arn:aws:acm:us-east-1:900734131342:certificate/placeholder-api-rookiecard" # TODO: Replace with actual certificate ARN
}

import {
  to = module.dns.aws_acm_certificate.api_the16oracles_io
  id = "arn:aws:acm:us-east-1:900734131342:certificate/placeholder-api-the16oracles" # TODO: Replace with actual certificate ARN
}

import {
  to = module.dns.aws_acm_certificate.svcs_the16oracles_io
  id = "arn:aws:acm:us-east-1:900734131342:certificate/placeholder-svcs-the16oracles" # TODO: Replace with actual certificate ARN
}

import {
  to = module.dns.aws_acm_certificate.www_the16oracles_io
  id = "arn:aws:acm:us-east-1:900734131342:certificate/placeholder-www-the16oracles" # TODO: Replace with actual certificate ARN
}

###############################################################################
# IAM Users
###############################################################################

import {
  to = module.iam.aws_iam_user.jhertz
  id = "jhertz"
}

import {
  to = module.iam.aws_iam_user.t16o_deploy
  id = "t16o-deploy"
}

import {
  to = module.iam.aws_iam_user.wgadberry
  id = "wgadberry"
}

###############################################################################
# IAM Roles
###############################################################################

import {
  to = module.iam.aws_iam_role.ec2_launch_wizard
  id = "AmazonEC2RoleForLaunchWizard"
}

import {
  to = module.iam.aws_iam_role.redshift_commands_access_20250611
  id = "AmazonRedshift-CommandsAccessRole-20250611T063358"
}

import {
  to = module.iam.aws_iam_role.redshift_commands_access_20251020
  id = "AmazonRedshift-CommandsAccessRole-20251020T232337"
}

import {
  to = module.iam.aws_iam_role.rds_monitoring_role
  id = "rds-monitoring-role"
}

###############################################################################
# IAM Policies
###############################################################################

import {
  to = module.iam.aws_iam_policy.billing_admin_access
  id = "arn:aws:iam::900734131342:policy/BillingAdminAccess"
}

import {
  to = module.iam.aws_iam_policy.redshift_commands_access_20250611
  id = "arn:aws:iam::900734131342:policy/AmazonRedshift-CommandsAccessPolicy-20250611T063358"
}

import {
  to = module.iam.aws_iam_policy.redshift_commands_access_20251020
  id = "arn:aws:iam::900734131342:policy/AmazonRedshift-CommandsAccessPolicy-20251020T232337"
}

###############################################################################
# IAM Role-Policy Attachments
###############################################################################

import {
  to = module.iam.aws_iam_role_policy_attachment.redshift_20250611_policy
  id = "AmazonRedshift-CommandsAccessRole-20250611T063358/arn:aws:iam::900734131342:policy/AmazonRedshift-CommandsAccessPolicy-20250611T063358"
}

import {
  to = module.iam.aws_iam_role_policy_attachment.redshift_20251020_policy
  id = "AmazonRedshift-CommandsAccessRole-20251020T232337/arn:aws:iam::900734131342:policy/AmazonRedshift-CommandsAccessPolicy-20251020T232337"
}

import {
  to = module.iam.aws_iam_role_policy_attachment.rds_monitoring_enhanced
  id = "rds-monitoring-role/arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

###############################################################################
# CloudWatch Log Groups
###############################################################################

import {
  to = module.monitoring.aws_cloudwatch_log_group.dynamodb_imports
  id = "/aws-dynamodb/imports"
}

import {
  to = module.monitoring.aws_cloudwatch_log_group.rds_os_metrics
  id = "RDSOSMetrics"
}
