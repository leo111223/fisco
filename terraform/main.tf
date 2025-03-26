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

# S3 for receipts
resource "aws_s3_bucket" "receipt_bucket" {
  bucket         = "fiscai-frontend-receipts"
  force_destroy  = true
}

# IAM for Amplify
data "aws_iam_role" "amplify_role" {
  name = "amplify-service-role"
}

resource "aws_iam_policy_attachment" "amplify_full_access" {
  name       = "amplify-full-access"
  roles      = [data.aws_iam_role.amplify_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# Amplify App
resource "aws_amplify_app" "plaid_app" {
  name         = "FiscAI"
  repository   = "https://github.com/leo111223/fisco.git"
  oauth_token  = var.github_token
  platform     = "WEB"
  iam_service_role_arn = data.aws_iam_role.amplify_role.arn
  enable_branch_auto_deletion = true

  environment_variables = {
    REACT_APP_ENV        = "production"
    REACT_APP_PLAID_ENV  = var.plaid_environment
  }

  auto_branch_creation_config {
    enable_auto_build          = true
    enable_pull_request_preview = false
    framework = "React"
    stage     = "PRODUCTION"
  }

  build_spec = <<EOT
version: 1
applications:
  - appRoot: fisc-ai/frontend
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - "**/*"
      cache:
        paths:
          - node_modules/**/*
  - appRoot: fisc-ai/python
    backend:
      phases:
        preBuild:
          commands:
            - pip install -r requirements.txt
        build:
          commands:
            - python server.py
      artifacts:
        baseDirectory: .
        files:
          - "**/*"
      cache:
        paths:
          - .venv/**/*
EOT


}

# Amplify Main Branch
resource "aws_amplify_branch" "main_branch" {
  app_id      = aws_amplify_app.plaid_app.id
  branch_name = var.branch_name
  stage       = "PRODUCTION"
  enable_auto_build = true

  environment_variables = {
    REACT_APP_ENV       = "production"
    REACT_APP_PLAID_ENV = var.plaid_environment
  }
}

# DynamoDB
resource "aws_dynamodb_table" "transactions" {
  name         = "transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "transaction_id"

  attribute {
    name = "transaction_id"
    type = "S"
  }
}

# Lambda Role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Lambda Function
resource "aws_lambda_function" "transaction_handler" {
  function_name = "lambda_function"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  timeout       = 10
  handler       = "lambda_link_token.handler"
  filename      = "lambda_function.zip"
  # filename      = "lambda_API.zip"

  environment {
    variables = {
      DYNAMODB_TABLE     = aws_dynamodb_table.transactions.name
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

# Lambda Policy
resource "aws_iam_policy_attachment" "lambda_execution" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API Gateway Setup
resource "aws_api_gateway_rest_api" "finance_api" {
  name        = "FinanceAPI"
  description = "API Gateway for Financial Transactions"
}

resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "transactions"
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
