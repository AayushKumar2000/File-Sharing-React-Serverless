
variable "function_name" {

}
variable "filename" {

}
variable "handler" {

}

variable "policy" {

}

variable "layer_arn" {
}

resource "aws_cloudwatch_log_group" "lf_cloudwatch_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14


}

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


resource "aws_iam_role_policy_attachment" "lambda_role" {
  count= length(var.policy)

  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = var.policy[count.index]
}



resource "aws_lambda_function" "test_lambda" {
  filename      = var.filename
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.handler
  runtime = "nodejs12.x"
  layers=[var.layer_arn]

 # for X-Ray tracing
  tracing_config {
    mode = "Active"
  }

 depends_on=[
   aws_cloudwatch_log_group.lf_cloudwatch_log_group,
   aws_iam_role_policy_attachment.lambda_role
]
}

output "lambda_arn"{
  value = aws_lambda_function.test_lambda.arn
}

output "lambda_name"{
  value=aws_lambda_function.test_lambda.function_name
}
