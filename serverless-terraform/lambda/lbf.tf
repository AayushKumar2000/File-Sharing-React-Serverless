

variable "dynamodb_arn" { }
variable "s3_bucket_arn" { }


  # lambda-function policy

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "addTagS3_addObjectTagging" {
  name        = "addTagS3_addObjectTagging"
  path        = "/"
  description = "add tag to s3 bucket objects"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": ["s3:PutObjectTagging"],
          "Resource": "${var.s3_bucket_arn}"
      }
  ]
}
EOF
}





resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "lambda_dynamodb"
  path        = "/"
  description = "IAM policy for dynamodb execution"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "${var.dynamodb_arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "xray_tracing" {
  name        = "xray_tracing"
  path        = "/"
  description = "for xray tracing in lambda functions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "xray:PutTraceSegments",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_layer_version" "lambda_layer_xray-sdk" {
  filename   = "D:/React/New folder/serverless-terraform/files/nodejs.zip"
  layer_name = "lambda_layer_xray-sdk"

  compatible_runtimes = ["nodejs12.x"]
}

#  lambda functions

module "function-module" {
 source="./lambda-function"

  function_name="downloadFile"
  filename="D:/React/New folder/serverless-terraform/files/downloadFile.zip"
  handler="downloadFile.handler"
  layer_arn= aws_lambda_layer_version.lambda_layer_xray-sdk.arn
  policy=[aws_iam_policy.lambda_logging.arn,aws_iam_policy.lambda_dynamodb.arn,aws_iam_policy.xray_tracing.arn]
}

module "function-uploadFile" {
source="./lambda-function"

  function_name="uploadFile"
  filename="D:/React/New folder/serverless-terraform/files/fileUpload.zip"
  handler="fileUpload.handler"
  layer_arn= aws_lambda_layer_version.lambda_layer_xray-sdk.arn
  policy=[aws_iam_policy.lambda_logging.arn,aws_iam_policy.lambda_dynamodb.arn,aws_iam_policy.xray_tracing.arn]
}

module "function-getFileDetails" {
source="./lambda-function"

  function_name="getFileDetails"
  filename="D:/React/New folder/serverless-terraform/files/getfiledetails.zip"
  handler="getfiledetails.handler"
  layer_arn= aws_lambda_layer_version.lambda_layer_xray-sdk.arn
  policy=[aws_iam_policy.lambda_logging.arn,aws_iam_policy.lambda_dynamodb.arn,aws_iam_policy.xray_tracing.arn]
}


module "function-zipFileDetails" {
  source="./lambda-function"

  function_name="zipFileDetails"
  filename="D:/React/New folder/serverless-terraform/files/zipdfileDetails.zip"
  handler= "zipfileDetails.handler"
  layer_arn= aws_lambda_layer_version.lambda_layer_xray-sdk.arn
  policy=[aws_iam_policy.lambda_logging.arn,aws_iam_policy.lambda_dynamodb.arn,aws_iam_policy.xray_tracing.arn]
}

module "function-addS3Tag" {
  source="./lambda-function"

  function_name="addS3Tag"
  filename="D:/React/New folder/serverless-terraform/files/addTagS3.zip"
  handler= "addTagS3.handler"
  layer_arn= aws_lambda_layer_version.lambda_layer_xray-sdk.arn
  policy=[aws_iam_policy.lambda_logging.arn,aws_iam_policy.lambda_dynamodb.arn
          ,aws_iam_policy.addTagS3_addObjectTagging.arn,aws_iam_policy.xray_tracing.arn ]
}
