provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}

# Lambda function
resource "aws_lambda_function" "function" {
  filename         = "function.zip"
  function_name    = "my-function"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = "${filebase64sha256("function.zip")}"
}

# IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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


# S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "leumi-task-bucket"
}

#Upload lambda function code to s3 bucket
resource "aws_s3_bucket_object" "function_code" {
  bucket = aws_s3_bucket.bucket.id
  key = "function.zip"
  source = "function.zip"
}

