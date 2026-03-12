###############################################################################
# Root Variables
###############################################################################

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "t16o"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "900734131342"
}
