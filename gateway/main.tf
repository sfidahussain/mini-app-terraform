resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = "service"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "service" {
  name = "pets.petstore"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.namespace.id

    dns_records {
      ttl  = 60
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_apigatewayv2_api" "petstore_api" {
  name          = "petstore"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "petstore_stage" {
  api_id = aws_apigatewayv2_api.petstore_api.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.petstore_api.id
  route_key = "GET /petstore/pets/{petId}"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.petstore_api.id
  integration_type = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.link.id

  integration_method = "ANY"
  integration_uri    = aws_service_discovery_service.service.arn  // AWS CloudMap Service
}

resource "aws_apigatewayv2_route" "put" {
  api_id    = aws_apigatewayv2_api.petstore_api.id
  route_key = "PUT /petstore/pets/{petId}"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.put_authorizer.id
}

resource "aws_apigatewayv2_vpc_link" "link" {
  name               = "vpc_link"
  security_group_ids = var.security_groups
  subnet_ids         = var.subnets.*.id

  tags = {
    Usage = "example"
  }
}

resource "aws_cognito_user_pool" "pool" {
  name = "mypool"
}

resource "aws_apigatewayv2_authorizer" "put_authorizer" {
  api_id           = aws_apigatewayv2_api.petstore_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "put-authorizer"

  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

output "service_arn" {
  value = aws_service_discovery_service.service.arn
}
