###############################################################################
# Network Load Balancer: nlb-api-gateway
###############################################################################

resource "aws_lb" "nlb_api_gateway" {
  name               = "nlb-api-gateway"
  internal           = false # TODO: Verify after import
  load_balancer_type = "network"

  subnets = var.subnet_ids

  tags = {
    Name = "nlb-api-gateway"
  }
}

###############################################################################
# Target Group: tg-api-gateway (TCP 5068)
###############################################################################

resource "aws_lb_target_group" "tg_api_gateway" {
  name        = "tg-api-gateway"
  port        = 5068
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name = "tg-api-gateway"
  }
}

###############################################################################
# Target Group: tg-t16o-api (TCP 5100)
###############################################################################

resource "aws_lb_target_group" "tg_t16o_api" {
  name        = "tg-t16o-api"
  port        = 5100
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name = "tg-t16o-api"
  }
}

###############################################################################
# NLB Listeners
# TODO: Add listener rules after import to map ports to target groups
###############################################################################

# resource "aws_lb_listener" "api_gateway" {
#   load_balancer_arn = aws_lb.nlb_api_gateway.arn
#   port              = 5068
#   protocol          = "TCP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg_api_gateway.arn
#   }
# }
#
# resource "aws_lb_listener" "t16o_api" {
#   load_balancer_arn = aws_lb.nlb_api_gateway.arn
#   port              = 5100
#   protocol          = "TCP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg_t16o_api.arn
#   }
# }
