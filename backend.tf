// Lambda function
resource "aws_iam_role" "iam_for_lambda2" {
  name = "iam_for_lambda2"
  assume_role_policy = file("assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy2" {
  name = "lambda_policy"
  role = aws_iam_role.iam_for_lambda2.id

  policy = templatefile("lambda_policy2.tpl", { 
      pricesTableArn = aws_dynamodb_table.stock_prices.arn
      hDataTableArn = aws_dynamodb_table.historical_data.arn
    })
}

resource "aws_lambda_function" "lambda_backend" {
  function_name = "backend"
  filename      = "./backend_lambda/backend.zip"
  source_code_hash = filebase64sha256("./backend_lambda/backend.zip")

  role          = aws_iam_role.iam_for_lambda2.arn
  handler       = "backend.lambda_handler"
  runtime       = "python3.8"
  timeout       = 3
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_lambda" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda_backend.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

// * API Gateway -----------------------------------------------------

locals {
  rest_api_id = aws_api_gateway_rest_api.api.id
  shareprice_res_id = aws_api_gateway_resource.shareprice.id
  shareprice_method = aws_api_gateway_method.method.http_method
  updatealarm_res_id = aws_api_gateway_resource.updatealarm.id
  updatealarm_method = aws_api_gateway_method.method2.http_method
  turnoff_res_id = aws_api_gateway_resource.turnoff.id
  turnoff_method = aws_api_gateway_method.method3.http_method
}

resource "aws_api_gateway_rest_api" "api" {
  name = "api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

// API Gateway SHAREPRICE resource, method, integration and responses
resource "aws_api_gateway_resource" "shareprice" {
  rest_api_id = local.rest_api_id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "shareprice"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = local.rest_api_id
  resource_id   = local.shareprice_res_id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.symbol" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = local.rest_api_id
  resource_id = local.shareprice_res_id
  http_method = local.shareprice_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda_backend.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = local.rest_api_id
  resource_id = local.shareprice_res_id
  http_method = local.shareprice_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = local.rest_api_id
  resource_id = local.shareprice_res_id
  http_method = local.shareprice_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = "Empty"
  }
}

// API Gateway UPDATEALARM resource, method, integration and responses
resource "aws_api_gateway_resource" "updatealarm" {
  rest_api_id = local.rest_api_id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "updatealarm"
}

resource "aws_api_gateway_method" "method2" {
  rest_api_id   = local.rest_api_id
  resource_id   = local.updatealarm_res_id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.symbol" = true
    "method.request.querystring.price" = true
  }
}

resource "aws_api_gateway_integration" "integration2" {
  rest_api_id = local.rest_api_id
  resource_id = local.updatealarm_res_id
  http_method = local.updatealarm_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda_backend.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_200_2" {
  rest_api_id = local.rest_api_id
  resource_id = local.updatealarm_res_id
  http_method = local.updatealarm_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response_2" {
  rest_api_id = local.rest_api_id
  resource_id = local.updatealarm_res_id
  http_method = local.updatealarm_method
  status_code = aws_api_gateway_method_response.response_200_2.status_code
  response_templates = {
    "application/json" = ""
  }
}

// API Gateway TURNOFF resource, method, integration and responses
resource "aws_api_gateway_resource" "turnoff" {
  rest_api_id = local.rest_api_id
  parent_id   = local.updatealarm_res_id
  path_part   = "turnoff"
}

resource "aws_api_gateway_method" "method3" {
  rest_api_id   = local.rest_api_id
  resource_id   = local.turnoff_res_id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.symbol" = true
  }
}

resource "aws_api_gateway_integration" "integration3" {
  rest_api_id = local.rest_api_id
  resource_id = local.turnoff_res_id
  http_method = local.turnoff_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda_backend.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "response_200_3" {
  rest_api_id = local.rest_api_id
  resource_id = local.turnoff_res_id
  http_method = local.turnoff_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response_3" {
  rest_api_id = local.rest_api_id
  resource_id = local.turnoff_res_id
  http_method = local.turnoff_method
  status_code = aws_api_gateway_method_response.response_200_3.status_code
  response_templates = {
    "application/json" = ""
  }
}

// API Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      local.shareprice_res_id,
      local.updatealarm_res_id,
      local.turnoff_res_id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_method.method2.id,
      aws_api_gateway_method.method3.id,
      aws_api_gateway_integration.integration.id,
      aws_api_gateway_integration.integration2.id,
      aws_api_gateway_integration.integration3.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}
