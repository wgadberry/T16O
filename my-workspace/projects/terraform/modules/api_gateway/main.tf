###############################################################################
# REST API: svcs.the16oracles.io
###############################################################################

resource "aws_api_gateway_rest_api" "svcs_the16oracles_io" {
  name        = "svcs.the16oracles.io"
  description = "API Gateway for svcs.the16oracles.io"

  endpoint_configuration {
    types = ["REGIONAL"] # TODO: Verify endpoint type after import
  }
}

resource "aws_api_gateway_deployment" "svcs_the16oracles_io_prod" {
  rest_api_id = aws_api_gateway_rest_api.svcs_the16oracles_io.id

  # TODO: Add triggers for redeployment based on resource/method changes
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "svcs_the16oracles_io_prod" {
  deployment_id = aws_api_gateway_deployment.svcs_the16oracles_io_prod.id
  rest_api_id   = aws_api_gateway_rest_api.svcs_the16oracles_io.id
  stage_name    = "prod"
}

# TODO: Add resources, methods, and integrations for svcs.the16oracles.io
# resource "aws_api_gateway_resource" "svcs_proxy" { ... }
# resource "aws_api_gateway_method" "svcs_proxy_any" { ... }
# resource "aws_api_gateway_integration" "svcs_proxy_integration" { ... }

###############################################################################
# REST API: api.the16oracles.io
###############################################################################

resource "aws_api_gateway_rest_api" "api_the16oracles_io" {
  name        = "api.the16oracles.io"
  description = "API Gateway for api.the16oracles.io"

  endpoint_configuration {
    types = ["REGIONAL"] # TODO: Verify endpoint type after import
  }
}

resource "aws_api_gateway_deployment" "api_the16oracles_io_prod" {
  rest_api_id = aws_api_gateway_rest_api.api_the16oracles_io.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_the16oracles_io_prod" {
  deployment_id = aws_api_gateway_deployment.api_the16oracles_io_prod.id
  rest_api_id   = aws_api_gateway_rest_api.api_the16oracles_io.id
  stage_name    = "prod"
}

# TODO: Add resources, methods, and integrations for api.the16oracles.io
# resource "aws_api_gateway_resource" "api_proxy" { ... }
# resource "aws_api_gateway_method" "api_proxy_any" { ... }
# resource "aws_api_gateway_integration" "api_proxy_integration" { ... }

###############################################################################
# REST API: www.the16oracles.io (no stages)
###############################################################################

resource "aws_api_gateway_rest_api" "www_the16oracles_io" {
  name        = "www.the16oracles.io"
  description = "API Gateway for www.the16oracles.io"

  endpoint_configuration {
    types = ["REGIONAL"] # TODO: Verify endpoint type after import
  }
}

# NOTE: No stages deployed for www.the16oracles.io

# TODO: Add resources, methods, and integrations for www.the16oracles.io
# resource "aws_api_gateway_resource" "www_proxy" { ... }
# resource "aws_api_gateway_method" "www_proxy_any" { ... }
# resource "aws_api_gateway_integration" "www_proxy_integration" { ... }
