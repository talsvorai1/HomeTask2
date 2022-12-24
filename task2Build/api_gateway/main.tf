provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}

resource "aws_api_gateway_rest_api" "my-api" {
  name        = "my-api"
  description = "my API Gateway"
}

# Method
resource "aws_api_gateway_method" "my-api" {
  rest_api_id   = aws_api_gateway_rest_api.my-api.id
  resource_id   = aws_api_gateway_rest_api.my-api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}
