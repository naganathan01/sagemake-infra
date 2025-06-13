
# terraform/api_gateway.tf - API Gateway Resources
resource "aws_api_gateway_rest_api" "diabetes_api" {
  count       = var.enable_api_gateway ? 1 : 0
  name        = "${local.name_prefix}-api"
  description = "Diabetes risk prediction API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.common_tags
}

resource "aws_api_gateway_resource" "predict_resource" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.diabetes_api[0].id
  parent_id   = aws_api_gateway_rest_api.diabetes_api[0].root_resource_id
  path_part   = "predict"
}

resource "aws_api_gateway_method" "predict_method" {
  count         = var.enable_api_gateway ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.diabetes_api[0].id
  resource_id   = aws_api_gateway_resource.predict_resource[0].id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sagemaker_integration" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.diabetes_api[0].id
  resource_id = aws_api_gateway_resource.predict_resource[0].id
  http_method = aws_api_gateway_method.predict_method[0].http_method

  integration_http_method = "POST"
  type                   = "AWS"
  uri                    = "arn:aws:apigateway:${var.aws_region}:runtime.sagemaker:path/endpoints/${local.name_prefix}-endpoint/invocations"
  credentials            = var.enable_api_gateway ? aws_iam_role.api_gateway_role[0].arn : null
}

resource "aws_api_gateway_method_response" "predict_response" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.diabetes_api[0].id
  resource_id = aws_api_gateway_resource.predict_resource[0].id
  http_method = aws_api_gateway_method.predict_method[0].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "predict_integration_response" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.diabetes_api[0].id
  resource_id = aws_api_gateway_resource.predict_resource[0].id
  http_method = aws_api_gateway_method.predict_method[0].http_method
  status_code = aws_api_gateway_method_response.predict_response[0].status_code

  depends_on = [aws_api_gateway_integration.sagemaker_integration]
}

resource "aws_api_gateway_deployment" "diabetes_api_deployment" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.diabetes_api[0].id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_method.predict_method,
    aws_api_gateway_integration.sagemaker_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.predict_resource[0].id,
      aws_api_gateway_method.predict_method[0].id,
      aws_api_gateway_integration.sagemaker_integration[0].id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.common_tags
}