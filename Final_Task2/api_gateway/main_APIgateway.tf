provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}

#Importing function
data "aws_lambda_function" "function" {
  function_name = "my-function"
}
#Importing IAM role
data "aws_iam_role" "hello_lambda_exec" {
  name = "hello-lambda"
}
#Creating gateway
resource "aws_api_gateway_rest_api" "my-api" {
  name        = "my-api"
  description = "My API"
}

resource "aws_api_gateway_resource" "my-api" {
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  parent_id   = aws_api_gateway_rest_api.my-api.root_resource_id
  path_part   = "my-api"
}

#Creating GET method
resource "aws_api_gateway_method" "my-api" {
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
  resource_id   = aws_api_gateway_resource.my-api.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = false
}
#Integrating method with Lambda function
resource "aws_api_gateway_integration" "my-api" {
  depends_on    = [aws_api_gateway_method.my-api]
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  resource_id = aws_api_gateway_resource.my-api.id
  http_method = aws_api_gateway_method.my-api.http_method
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.function.invoke_arn
  integration_http_method = "POST"
}
#Deploying - To access url it is in api gateway stages: prod
resource "aws_api_gateway_deployment" "my-api" {
  rest_api_id = aws_api_gateway_rest_api.my-api.id
  stage_name  = "prod"
}
