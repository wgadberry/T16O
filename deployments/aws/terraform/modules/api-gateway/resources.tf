# API Gateway Resources and Methods
# Defines all API endpoints and their integrations

# =============================================================================
# GUIDE GATEWAY ENDPOINTS (/guide/*)
# =============================================================================

resource "aws_api_gateway_resource" "guide" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "guide"
}

# POST /guide/trigger/{worker}
resource "aws_api_gateway_resource" "guide_trigger" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "trigger"
}

resource "aws_api_gateway_resource" "guide_trigger_worker" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide_trigger.id
  path_part   = "{worker}"
}

resource "aws_api_gateway_method" "guide_trigger_worker_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_trigger_worker.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.worker" = true
  }
}

resource "aws_api_gateway_integration" "guide_trigger_worker_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_trigger_worker.id
  http_method             = aws_api_gateway_method.guide_trigger_worker_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/trigger/{worker}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.worker" = "method.request.path.worker"
  }
}

# GET /guide/status/{request_id}
resource "aws_api_gateway_resource" "guide_status" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "status"
}

resource "aws_api_gateway_resource" "guide_status_request_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide_status.id
  path_part   = "{request_id}"
}

resource "aws_api_gateway_method" "guide_status_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_status_request_id.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.request_id" = true
  }
}

resource "aws_api_gateway_integration" "guide_status_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_status_request_id.id
  http_method             = aws_api_gateway_method.guide_status_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/status/{request_id}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.request_id" = "method.request.path.request_id"
  }
}

# GET /guide/pipeline/{correlation_id}
resource "aws_api_gateway_resource" "guide_pipeline" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "pipeline"
}

resource "aws_api_gateway_resource" "guide_pipeline_correlation_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide_pipeline.id
  path_part   = "{correlation_id}"
}

resource "aws_api_gateway_method" "guide_pipeline_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_pipeline_correlation_id.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.correlation_id" = true
  }
}

resource "aws_api_gateway_integration" "guide_pipeline_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_pipeline_correlation_id.id
  http_method             = aws_api_gateway_method.guide_pipeline_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/pipeline/{correlation_id}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.correlation_id" = "method.request.path.correlation_id"
  }
}

# GET /guide/workers
resource "aws_api_gateway_resource" "guide_workers" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "workers"
}

resource "aws_api_gateway_method" "guide_workers_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_workers.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "guide_workers_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_workers.id
  http_method             = aws_api_gateway_method.guide_workers_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/workers"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
}

# GET /guide/health
resource "aws_api_gateway_resource" "guide_health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "health"
}

resource "aws_api_gateway_method" "guide_health_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_health.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "guide_health_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_health.id
  http_method             = aws_api_gateway_method.guide_health_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/health"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
}

# POST /guide/cascade
resource "aws_api_gateway_resource" "guide_cascade" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.guide.id
  path_part   = "cascade"
}

resource "aws_api_gateway_method" "guide_cascade_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.guide_cascade.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "guide_cascade_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.guide_cascade.id
  http_method             = aws_api_gateway_method.guide_cascade_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.guide_gateway_port}/api/cascade"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
}

# =============================================================================
# SITE API ENDPOINTS (/site/*)
# =============================================================================

resource "aws_api_gateway_resource" "site" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "site"
}

# GET /site/owner/{address}
resource "aws_api_gateway_resource" "site_owner" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.site.id
  path_part   = "owner"
}

resource "aws_api_gateway_resource" "site_owner_address" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.site_owner.id
  path_part   = "{address}"
}

resource "aws_api_gateway_method" "site_owner_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.site_owner_address.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.address" = true
  }
}

resource "aws_api_gateway_integration" "site_owner_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.site_owner_address.id
  http_method             = aws_api_gateway_method.site_owner_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.site_api_port}/api/owner/{address}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.address" = "method.request.path.address"
  }
}

# GET /site/signature/{signature}
resource "aws_api_gateway_resource" "site_signature" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.site.id
  path_part   = "signature"
}

resource "aws_api_gateway_resource" "site_signature_sig" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.site_signature.id
  path_part   = "{signature}"
}

resource "aws_api_gateway_method" "site_signature_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.site_signature_sig.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.signature" = true
  }
}

resource "aws_api_gateway_integration" "site_signature_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.site_signature_sig.id
  http_method             = aws_api_gateway_method.site_signature_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.site_api_port}/api/signature/{signature}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.signature" = "method.request.path.signature"
  }
}

# POST /site/signatures
resource "aws_api_gateway_resource" "site_signatures" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.site.id
  path_part   = "signatures"
}

resource "aws_api_gateway_method" "site_signatures_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.site_signatures.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "site_signatures_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.site_signatures.id
  http_method             = aws_api_gateway_method.site_signatures_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.site_api_port}/api/signatures"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
}

# =============================================================================
# CLUSTER MAP API ENDPOINTS (/bmap/*, /wallet/*, /funder/*)
# Using proxy resources to catch all sub-paths
# =============================================================================

# /bmap/{proxy+}
resource "aws_api_gateway_resource" "bmap" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "bmap"
}

resource "aws_api_gateway_resource" "bmap_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.bmap.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "bmap_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.bmap_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "bmap_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.bmap_proxy.id
  http_method             = aws_api_gateway_method.bmap_proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.cluster_apis_port}/bmap/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# /wallet/{proxy+}
resource "aws_api_gateway_resource" "wallet" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "wallet"
}

resource "aws_api_gateway_resource" "wallet_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.wallet.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "wallet_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.wallet_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "wallet_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.wallet_proxy.id
  http_method             = aws_api_gateway_method.wallet_proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.cluster_apis_port}/wallet/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# /funder/{proxy+}
resource "aws_api_gateway_resource" "funder" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "funder"
}

resource "aws_api_gateway_resource" "funder_proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.funder.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "funder_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.funder_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "funder_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.funder_proxy.id
  http_method             = aws_api_gateway_method.funder_proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.nlb_dns_name}:${var.cluster_apis_port}/funder/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
