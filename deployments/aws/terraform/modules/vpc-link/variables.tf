variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  type        = string
}

variable "guide_gateway_port" {
  description = "Port for the Guide Gateway service"
  type        = number
  default     = 5100
}

variable "site_api_port" {
  description = "Port for the Site API service"
  type        = number
  default     = 5000
}

variable "cluster_apis_port" {
  description = "Port for the Cluster Map APIs"
  type        = number
  default     = 5100
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
