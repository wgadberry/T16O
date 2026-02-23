variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "EC2 key pair name (must exist in AWS)"
  type        = string
  default     = "t160_v1_services"
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 30
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH, RabbitMQ mgmt, and MySQL access"
  type        = string
  default     = "0.0.0.0/0"
}
