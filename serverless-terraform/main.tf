
provider "aws" {
  region = "us-east-1"
}

# dynamoDB module

module "dynamodb-module"{
  source = "./dynamoDB"
  db_name= "file_details"
}


# s3 public bucket for stroing files

module "s3-public-module" {
  source = "./s3-public"

  bucket_name="filesharing2000"
}


# lambda-function module

module "lb-downloadFile" {
  source = "./lambda"

  function_name = "downloadFile"
  handler = "downloadFile.handler"
  filename =  "./files/downloadFile.zip"
  create_layer = true
  lambda_layer_file_path = "./files/nodejs.zip"
  lambda_layer_name = "lambda_layer_xray-sdk"
  lambda_dynamodb_policy = true
  create_xRayTracing = true

  dynamodb_arn= module.dynamodb-module.dynamodb_table_arn

}

module "lb-uploadFile" {
  source = "./lambda"

  function_name = "uploadFile"
  handler = "fileUpload.handler"
  filename =  "./files/fileUpload.zip"
  create_layer = true
  lambda_layer_file_path = "./files/nodejs.zip"
  lambda_layer_name = "lambda_layer_xray-sdk"
  lambda_dynamodb_policy = true
  create_xRayTracing = true

  dynamodb_arn= module.dynamodb-module.dynamodb_table_arn

}


module "lb-addS3Tag" {
  source = "./lambda"

  function_name = "addS3Tag"
  handler = "addTagS3.handler"
  filename =  "./files/addTagS3.zip"
  create_layer = true
  lambda_layer_file_path = "./files/nodejs.zip"
  lambda_layer_name = "lambda_layer_xray-sdk"
  lambda_dynamodb_policy = true
  create_xRayTracing = true
  create_dead_letter_queue = true
  lambda_s3_object_tagging = true

  dynamodb_arn= module.dynamodb-module.dynamodb_table_arn
  sqs_arn= module.sqs_queue.sqs_queue_arn
  s3_bucket_arn= module.s3-public-module.s3-bucket_arn
  s3_bucket_id= module.s3-public-module.s3-bucket_id
}


# sqs queue
module "sqs_queue" {
  source = "./sqs"
}

# api gateway
module "api-gateway_module-fileDownload" {
  source = "./api-gateway"

  api_name = "fileDownload"
  api_description= "this is a api for downloading files through file-sharing"
  api_endpoint= "REGIONAL"
  api_deployment_stage_name = "Dev"
  api-method_integration = ["lambda","dynamodb"]


  api_resource_path = ["presignedurl","getfiledetails"]
  api_integration_type = ["AWS_PROXY", "AWS"]
  api_http_method = ["GET","GET"]
  integration_uri = [ module.lb-downloadFile.lambda_invoke_arn,"arn:aws:apigateway:us-east-1:dynamodb:action/GetItem" ]
  lambda_function_name =  module.lb-downloadFile.lambda_name
  dynamodb_arn = module.dynamodb-module.dynamodb_table_arn

 enable_cache = true
 cache_size = 0.5
 enable_cache_in_method = [false,true]
 cache_ttl = 300
 cache_key_parameters = [[],["method.request.querystring.fid"]]

 define_request_parameters = [true,true]
 request_parameters = [
    {
      resource_path = "presignedurl"
      parameter_list = ["method.request.querystring.fid"]
      parameter_value = ["true"]
     },
    {
      resource_path = "getfiledetails"
      parameter_list = ["method.request.querystring.fid"]
      parameter_value = ["true"]
    }
 ]

 enable_request_validator = [true,true]
 validate_body = [false,false]
 validate_request_parameters = [ true , true]
  request_template = <<-EOT
   {
    "TableName":"file_details",
    "Key":{
     "fileID": {
      "S": "$input.params('id')"
      }
    }
   }
  EOT

  response_template = <<-EOT
  #set($elem = $input.path('$'))

#if($elem == {})
{

}
#else
 {
 "fileID": "$elem.Item.fileID.S",
 "fileSize": "$elem.Item.fileSize.S",
 "fileName": "$elem.Item.fileName.S",
 "currentDownloads": "$elem.Item.currentDownloads.N",
 "totalDownloads": "$elem.Item.totalDownloads.N",
 "expireValue": "$elem.Item.expireValue.S",
 "zipFileDetails":[
    #foreach($map in $elem.Item.zipFileDetails.L){
       "fileName": "$map.M.fileName.S",
       "fileSize": "$map.M.fileSize.S"
    }#if($foreach.hasNext),#end
 #end
]
}

#end
  EOT

create_request_model = false

}



module "api-gateway_module-fileUpload" {
  source = "./api-gateway"

  api_name = "fileUpload"
  api_description= "this is a api for upload files through file-sharing"
  api_endpoint= "REGIONAL"
  api_deployment_stage_name = "Dev"
  api-method_integration = ["lambda","dynamodb"]


  api_resource_path = ["presignedurl","filedetails"]
  api_integration_type = ["AWS_PROXY", "AWS"]
  api_http_method = ["GET","POST"]
  integration_uri = [ module.lb-uploadFile.lambda_invoke_arn,"arn:aws:apigateway:us-east-1:dynamodb:action/PutItem" ]
  lambda_function_name =  module.lb-uploadFile.lambda_name
  dynamodb_arn = module.dynamodb-module.dynamodb_table_arn


  request_template = <<-EOT
  #set($inputRoot = $input.path('$'))
{
  "TableName": "file_details",
  "Item":{
       "fileID":{
         "S": "$context.requestId"
         },
       "fileName":{
          "S":"$input.path('$.fileName')"
         },
      "fileSize":{
         "S":"$input.path('$.fileSize')"
        },
       "expireValue":{
         "S":"$input.path('$.expireValue')"
        },
      "currentDownloads":{
         "N": "0"
        },
      "totalDownloads":{
        "N": "$input.path('$.totalDownloads')"
        },
      "zipFileDetails":{
         "L":[
              #foreach($map in $inputRoot.zipFileDetails){
              "M":{
               "fileName":{"S": "$map.fileName" },
                "fileSize":{"S": "$map.fileSize"}
               }
             }#if($foreach.hasNext),#end
           #end
         ]
       }
 }
}
  EOT

  response_template = <<-EOT
   #set($elem = $input.path('$'))
   {
    "fileID": "$context.requestId"
   }
  EOT

  enable_cache = false

  define_request_parameters = [true,false]
  request_parameters = [
     {
       resource_path = "presignedurl"
       parameter_list = ["method.request.querystring.fid"]
       parameter_value = ["true"]
      },
     { }
  ]


  enable_request_validator = [true,true]
  validate_body = [false, true]
 validate_request_parameters = [ true , false]
 create_request_model = true
 model_name = "requestValidation"
 method_request_validator_name = ["Empty","requestValidation"]
 model_schema = <<-EOT
 {
 "$schema": "http://json-schema.org/draft-04/schema#",
   "title": "test",
   "type": "object",
   "properties": {
       "fileName":{"type":"string"},
        "fileSize":{"type":"string"},
       "expireValue":{"type":"string"},
       "totalDownloads":{"type":"integer"},
       "zipFileDetails":{
            "type":"array",
            "items":{
                "type": "object",
                "properties":{
                  "fileName":{"type":"string"},
                  "fileSize":{"type":"string"}
            },

            "required":["fileName","fileSize"]

    }
     }
   },
   "required": ["fileName", "fileSize","expireValue","totalDownloads","zipFileDetails"]
}
 EOT
}


# inserting api url in the react .env file
resource "null_resource" "react_env_file" {

  provisioner "local-exec" {
    command = "echo REACT_APP_UPLOAD_URL=${module.api-gateway_module-fileUpload.api-deployment-url} > ../file-sharing/.env"
    // working_dir="D:\\React\\New folder\\file-sharing"
  }

  provisioner "local-exec" {
    command = "echo REACT_APP_DOWNLOAD_URL=${module.api-gateway_module-fileDownload.api-deployment-url} >> ../file-sharing/.env"
    // working_dir="D:\\React\\New folder\\file-sharing"

  }
}

module "webhosting" {
  source = "./s3-webhosting"

  bucket-name = "file-sharing-application"
  index-document ="index.html"
  file-path = "../file-sharing/build"
  upload-files = false

}

output "website-url" {
  value = module.webhosting.website-endpoint
}
