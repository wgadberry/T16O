# Network Load Balancer Module
# Creates NLB, target groups, and listeners for API services

resource "aws_lb" "api" {
  name               = "${var.name_prefix}-api-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-api-nlb"
  })
}

# Target Group for Guide Gateway (Flask API on port 5100)
resource "aws_lb_target_group" "guide_gateway" {
  name        = "${var.name_prefix}-guide-gw-tg"
  port        = var.guide_gateway_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/api/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guide-gateway-tg"
  })
}

# Target Group for Site API (C# API on port 5000)
resource "aws_lb_target_group" "site_api" {
  name        = "${var.name_prefix}-site-api-tg"
  port        = var.site_api_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-site-api-tg"
  })
}

# Target Group for Cluster Map APIs (Flask APIs)
resource "aws_lb_target_group" "cluster_apis" {
  name        = "${var.name_prefix}-cluster-api-tg"
  port        = var.cluster_apis_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster-apis-tg"
  })
}

# Listener for Guide Gateway
resource "aws_lb_listener" "guide_gateway" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.guide_gateway_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.guide_gateway.arn
  }
}

# Listener for Site API
resource "aws_lb_listener" "site_api" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.site_api_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.site_api.arn
  }
}

# Listener for Cluster APIs
resource "aws_lb_listener" "cluster_apis" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.cluster_apis_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cluster_apis.arn
  }
}

# Register EC2 instances with target groups
resource "aws_lb_target_group_attachment" "guide_gateway" {
  for_each = toset(var.guide_gateway_instance_ids)

  target_group_arn = aws_lb_target_group.guide_gateway.arn
  target_id        = each.value
  port             = var.guide_gateway_port
}

resource "aws_lb_target_group_attachment" "site_api" {
  for_each = toset(var.site_api_instance_ids)

  target_group_arn = aws_lb_target_group.site_api.arn
  target_id        = each.value
  port             = var.site_api_port
}

resource "aws_lb_target_group_attachment" "cluster_apis" {
  for_each = toset(var.cluster_apis_instance_ids)

  target_group_arn = aws_lb_target_group.cluster_apis.arn
  target_id        = each.value
  port             = var.cluster_apis_port
}
