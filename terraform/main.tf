# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-leo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM Role for AWS Amplify (Reference existing role instead of creating a new one)
data "aws_iam_role" "amplify_role" {
  name = "amplify-service-role"
}

resource "aws_iam_policy_attachment" "amplify_full_access" {
  name       = "amplify-full-access"
  roles      = [data.aws_iam_role.amplify_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# AWS Amplify App (Without build_spec)
resource "aws_amplify_app" "plaid_app" {
  name       = "FiscAI"
  repository = "https://github.com/leo111223/fisco.git"
  oauth_token = var.github_token
  iam_service_role_arn = data.aws_iam_role.amplify_role.arn
  enable_branch_auto_deletion = true
}

resource "aws_amplify_branch" "main_branch" {
  app_id      = aws_amplify_app.plaid_app.id
  branch_name = var.branch_name
  enable_auto_build = true
  stage             = "PRODUCTION"
}

# DynamoDB Table
resource "aws_dynamodb_table" "transactions" {
  name           = "transactions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "transaction_id"

  attribute {
    name = "transaction_id"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# API Gateway
resource "aws_api_gateway_rest_api" "finance_api" {
  name        = "FinanceAPI"
  description = "API Gateway for Financial Transactions"
}

resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "transactions"
}

resource "aws_lambda_function" "transaction_handler" {
  function_name = "transaction_handler"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_API.zip"

  environment {
    variables = {
      DYNAMODB_TABLE     = aws_dynamodb_table.transactions.name
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

resource "aws_iam_policy_attachment" "lambda_execution" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_api_gateway_method" "transactions_post" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.transactions.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.transactions_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.transaction_handler.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transaction_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"
}

# S3 Bucket for Frontend Hosting
resource "aws_s3_bucket" "receipt_bucket" {
  bucket = "fiscai-frontend-receipts" # replace with your unique bucket name
  force_destroy = true
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "fiscai_distribution" {
  origin {
    domain_name = aws_s3_bucket.receipt_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "fiscai_user_pool" {
  name = "fiscai-user-pool"
}

resource "aws_cognito_user_pool_client" "fiscai_user_pool_client" {
  name         = "fiscai-client"
  user_pool_id = aws_cognito_user_pool.fiscai_user_pool.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
}
