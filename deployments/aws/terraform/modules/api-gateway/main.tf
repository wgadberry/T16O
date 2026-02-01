# API Gateway Module
# Creates REST API with VPC Link integration

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.name_prefix}-api"
  description = "API Gateway for T16O services"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-api"
  })
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      # Guide Gateway resources
      aws_api_gateway_resource.guide.id,
      aws_api_gateway_resource.guide_trigger.id,
      aws_api_gateway_resource.guide_trigger_worker.id,
      aws_api_gateway_resource.guide_status.id,
      aws_api_gateway_resource.guide_status_request_id.id,
      aws_api_gateway_resource.guide_pipeline.id,
      aws_api_gateway_resource.guide_pipeline_correlation_id.id,
      aws_api_gateway_resource.guide_workers.id,
      aws_api_gateway_resource.guide_health.id,
      aws_api_gateway_resource.guide_cascade.id,
      # Site API resources
      aws_api_gateway_resource.site.id,
      aws_api_gateway_resource.site_owner.id,
      aws_api_gateway_resource.site_owner_address.id,
      aws_api_gateway_resource.site_signature.id,
      aws_api_gateway_resource.site_signature_sig.id,
      aws_api_gateway_resource.site_signatures.id,
      # Cluster API resources
      aws_api_gateway_resource.bmap.id,
      aws_api_gateway_resource.wallet.id,
      aws_api_gateway_resource.funder.id,
      # Methods
      aws_api_gateway_method.guide_trigger_worker_post.id,
      aws_api_gateway_method.guide_status_get.id,
      aws_api_gateway_method.guide_pipeline_get.id,
      aws_api_gateway_method.guide_workers_get.id,
      aws_api_gateway_method.guide_health_get.id,
      aws_api_gateway_method.guide_cascade_post.id,
      aws_api_gateway_method.site_owner_get.id,
      aws_api_gateway_method.site_signature_get.id,
      aws_api_gateway_method.site_signatures_post.id,
      aws_api_gateway_method.bmap_proxy.id,
      aws_api_gateway_method.wallet_proxy.id,
      aws_api_gateway_method.funder_proxy.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.guide_trigger_worker_post,
    aws_api_gateway_integration.guide_status_get,
    aws_api_gateway_integration.guide_pipeline_get,
    aws_api_gateway_integration.guide_workers_get,
    aws_api_gateway_integration.guide_health_get,
    aws_api_gateway_integration.guide_cascade_post,
    aws_api_gateway_integration.site_owner_get,
    aws_api_gateway_integration.site_signature_get,
    aws_api_gateway_integration.site_signatures_post,
    aws_api_gateway_integration.bmap_proxy,
    aws_api_gateway_integration.wallet_proxy,
    aws_api_gateway_integration.funder_proxy,
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      ip                = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      resourcePath      = "$context.resourcePath"
      status            = "$context.status"
      protocol          = "$context.protocol"
      responseLength    = "$context.responseLength"
      integrationStatus = "$context.integrationStatus"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.stage_name}"
  })
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${var.name_prefix}-api"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# API Key
resource "aws_api_gateway_api_key" "main" {
  name        = "${var.name_prefix}-api-key"
  description = "API Key for T16O API Gateway"
  enabled     = true

  tags = var.tags
}

# Usage Plan
resource "aws_api_gateway_usage_plan" "main" {
  name        = "${var.name_prefix}-usage-plan"
  description = "Usage plan for T16O API"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  throttle_settings {
    rate_limit  = var.rate_limit
    burst_limit = var.burst_limit
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }

  tags = var.tags
}

# Associate API Key with Usage Plan
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# Method Settings for all methods (enable logging)
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    data_trace_enabled = var.enable_data_trace
    metrics_enabled    = true
  }
}
