# T16O API Gateway Infrastructure
# Terraform configuration for AWS API Gateway with VPC Link integration

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state storage
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "t16o/api-gateway/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "T16O"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Network Load Balancer Module
module "nlb" {
  source = "./modules/nlb"

  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  guide_gateway_port = var.guide_gateway_port
  site_api_port      = var.site_api_port
  cluster_apis_port  = var.cluster_apis_port

  guide_gateway_instance_ids = var.guide_gateway_instance_ids
  site_api_instance_ids      = var.site_api_instance_ids
  cluster_apis_instance_ids  = var.cluster_apis_instance_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

# VPC Link Module
module "vpc_link" {
  source = "./modules/vpc-link"

  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id
  vpc_cidr    = var.vpc_cidr
  nlb_arn     = module.nlb.nlb_arn

  guide_gateway_port = var.guide_gateway_port
  site_api_port      = var.site_api_port
  cluster_apis_port  = var.cluster_apis_port

  tags = var.tags
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"

  name_prefix  = var.name_prefix
  vpc_link_id  = module.vpc_link.vpc_link_id
  nlb_dns_name = module.nlb.nlb_dns_name

  guide_gateway_port = var.guide_gateway_port
  site_api_port      = var.site_api_port
  cluster_apis_port  = var.cluster_apis_port

  stage_name         = var.stage_name
  rate_limit         = var.rate_limit
  burst_limit        = var.burst_limit
  quota_limit        = var.quota_limit
  quota_period       = var.quota_period
  log_retention_days = var.log_retention_days
  enable_data_trace  = var.enable_data_trace

  tags = var.tags
}
