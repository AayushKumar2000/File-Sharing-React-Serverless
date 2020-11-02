variable "function_name" {
description = "lambda function name"
type = string
default = null
}
variable "filename" {
description = "lambda function file path"
type = string
default = null
}
variable "handler" {
description = "lambda handler  name"
type = string
default = null
}


variable "create_layer" {
  description = "layer for the lambda function"
  type = bool
  default = false
}

variable "lambda_layer_file_path" {
  description = "file for the lambda layer"
  type = string
  default = null
}

variable "lambda_layer_name" {
  description = "lambda layer name"
  type = string
  default = null
}

variable "lambda_runtime" {
  description = "runtime for the lambda function"
  default = "nodejs12.x"
}

variable "create_xRayTracing" {
  description = "create aws xray tracing for lambda function"
  type = bool
  default = false
}

variable "lambda_dynamodb_policy" {
  description = "create a policy for lambda to execute dynamodb operations"
  type = bool
  default = false
}

variable "create_dead_letter_queue" {
  description = "create a dead letter queue for the lambda function"
  type = bool
  default = false
}

variable "lambda_s3_object_tagging" {
  description = "to add tag to s3 object from a lambda function"
  type = bool
  default = false
}



variable "dynamodb_arn" {
  default = null
}

variable "sqs_arn" {
  default = null
}

variable "s3_bucket_arn" {
  default = null
}

variable "s3_bucket_id" {
  default = null
}
