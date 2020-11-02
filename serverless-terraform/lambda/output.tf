
output "lambda_arn"{
  value = aws_lambda_function.test_lambda.arn
}

output "lambda_name"{
  value=aws_lambda_function.test_lambda.function_name
}

output "lambda_invoke_arn" {
 value = aws_lambda_function.test_lambda.invoke_arn

}
