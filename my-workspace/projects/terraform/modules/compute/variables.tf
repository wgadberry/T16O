###############################################################################
# Compute Module Variables
###############################################################################

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for EBS volumes"
  type        = string
}

variable "sg_velintra_id" {
  description = "Security group ID for velintraOS instance"
  type        = string
}

variable "sg_t16o_v1_services_id" {
  description = "Security group ID for t16o v1 services instance"
  type        = string
}
