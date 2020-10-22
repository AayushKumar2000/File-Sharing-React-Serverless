
variable "resource_path" {}

variable "api" {}

variable "http_method" {}

variable "lambda_fun_name" {}

variable "integration_http_method" {}


# lambda data source
data "aws_lambda_function" "existing" {
  function_name = var.lambda_fun_name
}

# aws account ID
data "aws_caller_identity" "current" {}

# aws region
data "aws_region" "current" {}

resource "aws_api_gateway_resource" "resource" {
  path_part   =var.resource_path
  parent_id   = var.api.root_resource_id
  rest_api_id = var.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {


  rest_api_id             = var.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = var.integration_http_method
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.existing.invoke_arn
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_fun_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

# to enable coros
module "cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.1"

  api_id          = var.api.id
  api_resource_id = aws_api_gateway_resource.resource.id
}

# response method

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id =var.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  response_models={
    "application/json"="Empty"
  }
}


resource "aws_api_gateway_integration_response" "MyIntegrationResponse" {
  rest_api_id =var.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}
