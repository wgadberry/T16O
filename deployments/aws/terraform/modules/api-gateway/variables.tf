variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_link_id" {
  description = "ID of the VPC Link"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
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

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "prod"
}

variable "rate_limit" {
  description = "Rate limit for the usage plan (requests per second)"
  type        = number
  default     = 100
}

variable "burst_limit" {
  description = "Burst limit for the usage plan"
  type        = number
  default     = 200
}

variable "quota_limit" {
  description = "Quota limit for the usage plan"
  type        = number
  default     = 10000
}

variable "quota_period" {
  description = "Quota period for the usage plan (DAY, WEEK, or MONTH)"
  type        = string
  default     = "DAY"
}

variable "log_retention_days" {
  description = "Number of days to retain API Gateway logs"
  type        = number
  default     = 30
}

variable "enable_data_trace" {
  description = "Enable detailed request/response logging (may expose sensitive data)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
