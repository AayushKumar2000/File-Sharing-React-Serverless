

# ////////////////////
# xray-tracing

resource "aws_iam_policy" "xray_tracing" {
  count = var.create_xRayTracing  ? 1 : 0

  name        = "xray_tracing-${var.function_name}"
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

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  count = var.create_xRayTracing  ? 1 : 0

  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.xray_tracing[0].arn
}

# ///////////////////


 # lambda layer
resource "aws_lambda_layer_version" "lambda_layer_xray-sdk" {
  count = var.create_layer ? 1 : 0

  filename   = var.lambda_layer_file_path
  layer_name = var.lambda_layer_name
  compatible_runtimes = [var.lambda_runtime]
}






   # cloud watch log group and logs

resource "aws_cloudwatch_log_group" "lf_cloudwatch_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging-${var.function_name}"
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

resource "aws_iam_role_policy_attachment" "lambda_log" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}



# policy for dynamodb

resource "aws_iam_policy" "lambda_dynamodb" {
 count = var.lambda_dynamodb_policy ? 1 : 0

  name        = "lambda_dynamodb-${var.function_name}"
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

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  count = var.lambda_dynamodb_policy ? 1 : 0

  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_dynamodb[0].arn
}



#  policy for sqs

resource "aws_iam_policy" "sqs_dead_letter_queue" {
 count = var.create_dead_letter_queue ? 1 : 0

  name        = "sqs_dead_letter_queue-${var.function_name}"
  path        = "/"
  description = "policy to put message in sqs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sqs:SendMessage",
      "Effect": "Allow",
      "Resource": "${var.sqs_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs-dl" {
  count = var.create_dead_letter_queue ? 1 : 0

  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.sqs_dead_letter_queue[0].arn
}



#  s3 bucket object tagging
resource "aws_iam_policy" "addTagS3_addObjectTagging" {
count = var.lambda_s3_object_tagging ? 1 : 0

 name        = "addTagS3_addObjectTagging-${var.function_name}"
 path        = "/"
 description = "add tag to s3 bucket objects"

 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
     {
         "Effect": "Allow",
         "Action": ["s3:PutObjectTagging"],
         "Resource": "${var.s3_bucket_arn}/*"
     }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_addObjectTagging" {
  count = var.lambda_s3_object_tagging ? 1 : 0


  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.addTagS3_addObjectTagging[0].arn
}

# s3 object tagging lambda permission

resource "aws_lambda_permission" "allow_S3" {
count = var.lambda_s3_object_tagging ? 1 : 0

  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  count = var.lambda_s3_object_tagging ? 1 : 0

bucket = var.s3_bucket_id
lambda_function {
lambda_function_arn = aws_lambda_function.test_lambda.arn
events              = ["s3:ObjectCreated:Put"]
}
}




   # role for the lambda function

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_lambda_function" "test_lambda" {
  filename      = var.filename
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.handler
  runtime       = var.lambda_runtime
  layers        = [aws_lambda_layer_version.lambda_layer_xray-sdk[0].arn]



# x-ray tracing
dynamic "tracing_config" {
 for_each = var.create_xRayTracing  ? [true] : []
 content {
    mode = "Active"
 }
}

# sqs dead letter queue
dynamic "dead_letter_config" {
for_each = var.create_dead_letter_queue ? [true] : []
  content {
    target_arn = var.sqs_arn
  }
}

 depends_on=[
   aws_cloudwatch_log_group.lf_cloudwatch_log_group
]

}
