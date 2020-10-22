
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

module "lb-module" {
  source = "./lambda"

  dynamodb_arn= module.dynamodb-module.dynamodb_table_arn
  s3_bucket_arn= module.s3-public-module.s3-bucket_arn
  s3_bucket_id= module.s3-public-module.s3-bucket_id

}










# api gateway


variable "api-gateway" {
  default=[
    {
      api_name= "fileDownload"
      api_description= "this is a api for downloading files through file-sharing"
      api_endpoint= "REGIONAL"
      api_resource_count= 2
      api_resource_configuration=[
        {
          resource_path= "getfileDetails"
          http_method= "GET"
          integration_http_method= "POST"
          lambda_fun_name="getFileDetails"
        },

        {
          resource_path= "presignedurl"
          http_method= "GET"
          integration_http_method= "POST"
          lambda_fun_name="downloadFile"
        }
      ]
    },

    {
      api_name= "fileUpload"
      api_description= "this is a api for uploading files through file-sharing"
      api_endpoint= "REGIONAL"
      api_resource_count= 2
      api_resource_configuration=[
        {
          resource_path= "presignedurl"
          http_method= "GET"
          integration_http_method= "POST"
          lambda_fun_name="uploadFile"
        },

        {
          resource_path= "zipfiledetails"
          http_method= "POST"
          integration_http_method= "POST"
          lambda_fun_name="zipFileDetails"
        }
      ]

    }
  ]
}

# api getway module
#
module "api-gateway_module" {
  source = "./api-gateway"

  depends_on=[module.lb-module]

# no of api-gateway
  count= length(var.api-gateway)

  api_name= var.api-gateway[count.index].api_name
  api_description= var.api-gateway[count.index].api_description
  api_endpoint= var.api-gateway[count.index].api_endpoint
  api_resource_count= var.api-gateway[count.index].api_resource_count
  api_resource_configuration= var.api-gateway[count.index].api_resource_configuration
}



output "api-deployment-url"{
  value = module.api-gateway_module
}


# inserting api url in the react .env file
resource "null_resource" "react_env_file" {

  provisioner "local-exec" {
    command = "echo REACT_APP_UPLOAD_URL=${module.api-gateway_module[1].api-deployment-url} > .env"
     working_dir="D:\\React\\New folder\\file-sharing"
  }

  provisioner "local-exec" {
    command = "echo REACT_APP_DOWNLOAD_URL=${module.api-gateway_module[0].api-deployment-url} >> .env"
     working_dir="D:\\React\\New folder\\file-sharing"

  }
}
