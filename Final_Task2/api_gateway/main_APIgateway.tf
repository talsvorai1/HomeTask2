provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}

#Importing function
data "aws_lambda_function" "function" {
  function_name = "my-function"
}

#Creating gateway
resource "aws_api_gateway_rest_api" "new-api" {
  name        = "new-api"
  description = "My new API"
}

resource "aws_api_gateway_resource" "new-api" {
  rest_api_id = aws_api_gateway_rest_api.new-api.id
  parent_id   = aws_api_gateway_rest_api.new-api.root_resource_id
  path_part   = "new-api"
}

#Creating GET method
resource "aws_api_gateway_method" "new-api" {
  rest_api_id   = aws_api_gateway_rest_api.new-api.id
  resource_id   = aws_api_gateway_resource.new-api.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}
#Integrating method with Lambda function
resource "aws_api_gateway_integration" "new-api" {
  depends_on    = [aws_api_gateway_method.new-api]
  rest_api_id = aws_api_gateway_rest_api.new-api.id
  resource_id = aws_api_gateway_resource.new-api.id
  http_method = aws_api_gateway_method.new-api.http_method
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.function.invoke_arn
  integration_http_method = "POST"
}
#Deploying - To access url it is in api gateway stages: prod
resource "aws_api_gateway_deployment" "new-api" {
  rest_api_id = aws_api_gateway_rest_api.new-api.id
  stage_name  = "prod"
}
