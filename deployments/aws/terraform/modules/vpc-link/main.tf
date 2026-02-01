# VPC Link Module
# Creates API Gateway VPC Link to connect to the private NLB

resource "aws_api_gateway_vpc_link" "main" {
  name        = "${var.name_prefix}-vpc-link"
  description = "VPC Link for API Gateway to access internal NLB"
  target_arns = [var.nlb_arn]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-link"
  })
}

# Security group for the VPC Link (controls access to NLB)
resource "aws_security_group" "vpc_link" {
  name        = "${var.name_prefix}-vpc-link-sg"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from API Gateway to NLB ports
  ingress {
    description = "Guide Gateway API"
    from_port   = var.guide_gateway_port
    to_port     = var.guide_gateway_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Site API"
    from_port   = var.site_api_port
    to_port     = var.site_api_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Cluster APIs"
    from_port   = var.cluster_apis_port
    to_port     = var.cluster_apis_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-link-sg"
  })
}
