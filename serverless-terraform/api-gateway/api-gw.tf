
variable "api_name" {}

variable "api_description" {}

variable "api_endpoint" {}

variable "api_resource_count" {}

variable "api_resource_configuration" {}



resource "aws_api_gateway_rest_api" "fileDownloadAPI" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = [ var.api_endpoint ]
  }
 }


# api gateway resourse and method module

module "api_resource" {
  source = "./resources"

  count = var.api_resource_count

  resource_path= var.api_resource_configuration[count.index].resource_path
  api= aws_api_gateway_rest_api.fileDownloadAPI
  http_method= var.api_resource_configuration[count.index].http_method
  lambda_fun_name= var.api_resource_configuration[count.index].lambda_fun_name
  integration_http_method= var.api_resource_configuration[count.index].integration_http_method
}


#api gate-way deployment
resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = [module.api_resource]

  rest_api_id = aws_api_gateway_rest_api.fileDownloadAPI.id
  stage_name  = "test"

}

output "api-deployment-url"{
  value= aws_api_gateway_deployment.MyDemoDeployment.invoke_url
}

output "api-name"{
  value=  var.api_name
}
