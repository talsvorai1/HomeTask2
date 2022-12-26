provider "aws" {
    region = "us-east-1"
    shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}

# Lambda function
resource "aws_lambda_function" "function" {
  filename         = "function.zip"
  function_name    = "my-function"
  role             = "${aws_iam_role.hello_lambda_exec.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = "${filebase64sha256("function.zip")}"
}

# IAM role for the Lambda function
resource "aws_iam_role" "hello_lambda_exec" {
  name = "hello-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#IAM policy for role
resource "aws_iam_role_policy_attachment" "hello_lambda_policy" {
  role       = aws_iam_role.hello_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
