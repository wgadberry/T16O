###############################################################################
# Networking Module Variables
###############################################################################

variable "vpc_id" {
  description = "VPC ID for target groups"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the NLB"
  type        = list(string)
}
