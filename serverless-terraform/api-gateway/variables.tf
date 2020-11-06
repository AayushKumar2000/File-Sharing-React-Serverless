variable "api_name" {
  description = "name of the api gateway"
  type = string
  default = null
}

variable "dynamodb_arn" {
  type = string
  default = null
}

variable "enable_request_validator" {
  default = []
  type = list
}

variable "validate_body" {
  default = []
  type = list
}

variable "validate_request_parameters" {
  default = []
  type = list
}

variable "model_name" {
  default = null
  type = string
}

variable "method_request_validator_enable" {
  default = []
  type = list
}

variable "method_request_validator_name" {
  default = []
  type = list
}

variable "create_request_model" {
  default = false
  type = bool
}

variable "model_schema" {
  default = null
  type = string
}

variable "request_template" {
  type = string
  default = "Empty"
}

variable "response_template" {
  type = string
  default = "Empty"
}

variable "api_description" {
  description = "description of the api gateway"
  type = string
  default = "api-gateway"
}

variable "api_endpoint" {
  description = "endpoint for your api gateway"
  type = string
  default = "REGIONAL"
}

variable "api_deployment_stage_name" {
  description = "name for the stage of your api development"
  type = string
  default = "dev"
}

variable "api-method_integration" {
  description = " integrattions with lambda function"
  type = list
  default = [ ]
}

variable "api_resource_path" {
  description = "resource in the api gateway"
  type = list
  default = []
}

variable "api_http_method" {
  description = "http method in the api gateway"
  type = list
  default = []
}

variable "api_integration_type" {
  default = []
  type = list
}



 variable "integration_uri" {
   default = []
   type = list
 }

 variable "lambda_function_name" {
   description = "lambda function to be integrated with"
   type = string
   default = null
 }
