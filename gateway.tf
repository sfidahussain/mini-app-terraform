# API Gateway That Will Contain 3 endpoints
# 1. Fetch Latest Rate
resource "aws_api_gateway_rest_api" "api" {
  name = "interest_api"
}

resource "aws_api_gateway_resource" "rate" {
  path_part   = "rate"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "latest" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.rate.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "latest_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.rate.id
  http_method             = aws_api_gateway_method.latest.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.func_latest.invoke_arn}"
}

resource "aws_api_gateway_method_response" "response_latest_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.rate.id
  http_method = aws_api_gateway_method.latest.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "LatestResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.rate.id
  http_method = aws_api_gateway_method.latest.http_method
  status_code = aws_api_gateway_method_response.response_latest_200.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.latest_integration
  ]
}

# 2. Fetch Specific Timestamp Rate
resource "aws_api_gateway_method" "specific" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.rate.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "specific_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.rate.id
  http_method             = aws_api_gateway_method.specific.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.func_specific.invoke_arn}"
}

resource "aws_api_gateway_method_response" "response_specific_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.rate.id
  http_method = aws_api_gateway_method.specific.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "SpecificResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.rate.id
  http_method = aws_api_gateway_method.specific.http_method
  status_code = aws_api_gateway_method_response.response_specific_200.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.specific_integration
  ]
}

# 3. Fetch All Rates
resource "aws_api_gateway_resource" "all" {
  path_part   = "all"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "all" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.all.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "all_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.all.id
  http_method             = aws_api_gateway_method.all.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.func_all.invoke_arn}"
}

resource "aws_api_gateway_method_response" "response_all_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.all.id
  http_method = aws_api_gateway_method.all.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "AllResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.all.id
  http_method = aws_api_gateway_method.all.http_method
  status_code = aws_api_gateway_method_response.response_all_200.status_code
  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.all_integration
  ]
}

# Lambda Permissions for API Gateway Endpoints
resource "aws_lambda_permission" "lambda_all" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func_all.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "lambda_specific" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func_specific.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "lambda_latest" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func_latest.function_name
  principal     = "apigateway.amazonaws.com"
}