output "api-deployment-url"{
  value= aws_api_gateway_deployment.MyDemoDeployment.invoke_url
}

output "api-name"{
  value=  var.api_name
}
