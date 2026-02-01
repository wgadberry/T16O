# =============================================================================
# AWS Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "t16o"
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the NLB"
  type        = list(string)
}

# =============================================================================
# EC2 Instance Configuration
# =============================================================================

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

# =============================================================================
# Service Ports
# =============================================================================

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

# =============================================================================
# API Gateway Configuration
# =============================================================================

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
  description = "Quota limit for the usage plan (requests per period)"
  type        = number
  default     = 10000
}

variable "quota_period" {
  description = "Quota period for the usage plan (DAY, WEEK, or MONTH)"
  type        = string
  default     = "DAY"

  validation {
    condition     = contains(["DAY", "WEEK", "MONTH"], var.quota_period)
    error_message = "quota_period must be one of: DAY, WEEK, MONTH"
  }
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

# =============================================================================
# General Configuration
# =============================================================================

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the NLB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
