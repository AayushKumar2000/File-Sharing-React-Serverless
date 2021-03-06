
locals {

  dynamodb_integration = contains(var.api-method_integration ,"dynamodb" )
  lambda_integration = contains(var.api-method_integration ,"lambda" )
  lambda_index = index(var.api-method_integration, "lambda")
  # dynamodb_index = index(var.api-method_integration, "dynamodb")

}



resource "aws_iam_role" "api-gateway" {

  count = local.dynamodb_integration  ? 1 : 0

  name = "${var.api_name}-api-gateway"
  description = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api-gateway-db" {

  count = local.dynamodb_integration  ? 1 : 0

  name = "DDBPolicy"
  role = aws_iam_role.api-gateway[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Resource": [
        "${var.dynamodb_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_api_gateway_request_validator" "myrequestvalidator" {
  count = length(var.enable_request_validator)

  name                        = "${var.api_resource_path[count.index]}-validator"
  rest_api_id                 = aws_api_gateway_rest_api.api_gateway.id
  validate_request_body       = var.validate_body[count.index]
  validate_request_parameters = var.validate_request_parameters[count.index]
}


resource "aws_api_gateway_model" "MyDemoModel" {
  count = var.create_request_model ? 1 : 0
  rest_api_id  = aws_api_gateway_rest_api.api_gateway.id
  name         = var.model_name
  description  = "a JSON schema"
  content_type = "application/json"

  schema = var.model_schema
}



resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = [ var.api_endpoint ]
  }
 }



#  api-gateway resource
resource "aws_api_gateway_resource" "resource" {
  count = length(var.api_resource_path)

  path_part   = var.api_resource_path[count.index]
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_method" "method" {
  count = length(var.api_http_method)

  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.resource[count.index].id
  http_method   = var.api_http_method[count.index]
  authorization = "NONE"

  request_models = {
    "application/json" = var.create_request_model? var.method_request_validator_name[count.index] : "Empty"
  }

  request_parameters = length(var.request_parameters) !=0 ?  var.define_request_parameters[count.index] == true ? zipmap(var.request_parameters[count.index].parameter_list,var.request_parameters[count.index].parameter_value) : null : null

  request_validator_id = var.enable_request_validator[count.index] ?  aws_api_gateway_request_validator.myrequestvalidator[count.index].id : null




  depends_on = [aws_api_gateway_model.MyDemoModel]
}


resource "aws_api_gateway_method_settings" "method_settings" {
  count = length(var.api_http_method)

  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  method_path = "${aws_api_gateway_resource.resource[count.index].path_part}/${aws_api_gateway_method.method[count.index].http_method}"
  stage_name = var.api_deployment_stage_name


    settings {
      caching_enabled = var.enable_cache ? var.enable_cache_in_method[count.index] : null
      cache_ttl_in_seconds = var.cache_ttl
    }


}

resource "aws_api_gateway_integration" "integration" {
count =  length(var.api_resource_path)

  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.resource[count.index].id
  http_method             = aws_api_gateway_method.method[count.index].http_method
  integration_http_method = "POST"
  type                    = var.api_integration_type[count.index]
  uri                     = var.integration_uri[count.index]
  credentials = var.api-method_integration[count.index] == "dynamodb" ? aws_iam_role.api-gateway[0].arn : null
  cache_key_parameters = length(var.cache_key_parameters) != 0 ? var.enable_cache_in_method[count.index] ? var.cache_key_parameters[count.index] : null : null


  request_templates = {
   "application/json" = var.api-method_integration[count.index] == "lambda" ? "Empty" : var.request_template

  }
}

# aws account ID
data "aws_caller_identity" "current" {}

# aws region
data "aws_region" "current" {}


resource "aws_lambda_permission" "apigw_lambda" {
  count = local.lambda_integration ? 1 : 0

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/${aws_api_gateway_method.method[local.lambda_index].http_method}${aws_api_gateway_resource.resource[local.lambda_index].path}"
}

# to enable coros
module "cors" {
  count = length(var.api_resource_path)
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.1"

  api_id          = aws_api_gateway_rest_api.api_gateway.id
  api_resource_id = aws_api_gateway_resource.resource[count.index].id
}

# response method

resource "aws_api_gateway_method_response" "response_200" {
  count = length(var.api_resource_path)

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.resource[count.index].id
  http_method = aws_api_gateway_method.method[count.index].http_method
  status_code = "200"

  response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }

}


resource "aws_api_gateway_integration_response" "MyIntegrationResponse" {
  count = length(var.api_resource_path)

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.resource[count.index].id
  http_method = aws_api_gateway_method.method[count.index].http_method
  status_code = aws_api_gateway_method_response.response_200[count.index].status_code
  response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
  response_templates = {
   "application/json" = var.api-method_integration[count.index] == "lambda" ? "Empty" : var.response_template
 }

 depends_on = [aws_api_gateway_integration.integration]


}

resource "aws_api_gateway_stage" "test" {
  stage_name    = var.api_deployment_stage_name
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.MyDemoDeployment.id

  cache_cluster_enabled = var.enable_cache
  cache_cluster_size = var.enable_cache ? var.cache_size : null
}



#api gate-way deployment
resource "aws_api_gateway_deployment" "MyDemoDeployment" {

  depends_on = [aws_api_gateway_integration_response.MyIntegrationResponse]

 rest_api_id = aws_api_gateway_rest_api.api_gateway.id


 triggers = {
   redeployment = sha1(join(",", list(
     jsonencode(aws_api_gateway_integration.integration),
     jsonencode(aws_api_gateway_resource.resource),
     jsonencode(aws_api_gateway_method.method)

   )))
 }

 lifecycle {
   create_before_destroy = true
 }

}
