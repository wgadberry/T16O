variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the NLB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the NLB"
  type        = list(string)
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

variable "guide_gateway_instance_ids" {
  description = "List of EC2 instance IDs running the Guide Gateway"
  type        = list(string)
}

variable "site_api_instance_ids" {
  description = "List of EC2 instance IDs running the Site API"
  type        = list(string)
}

variable "cluster_apis_instance_ids" {
  description = "List of EC2 instance IDs running the Cluster Map APIs"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the NLB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
