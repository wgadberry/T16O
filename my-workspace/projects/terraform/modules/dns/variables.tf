###############################################################################
# DNS Module Variables
###############################################################################

variable "nlb_dns_name" {
  description = "DNS name of the NLB for Route53 alias records"
  type        = string
}

variable "nlb_zone_id" {
  description = "Zone ID of the NLB for Route53 alias records"
  type        = string
}
