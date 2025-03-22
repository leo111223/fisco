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

# AWS Amplify App (With Plaid API Integration)
resource "aws_amplify_app" "plaid_app" {
  name       = var.app_name
  platform   = "WEB"
  repository = var.repo_url
 
  
  enable_auto_branch_creation = true
  
  environment_variables = {
    PLAID_CLIENT_ID     = var.plaid_client_id
    PLAID_SECRET        = var.plaid_secret
    PLAID_ENVIRONMENT   = var.plaid_environment
  }
  
  iam_service_role_arn = data.aws_iam_role.amplify_role.arn

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

# AWS Amplify Branch (Deploys Specific GitHub Branch)
resource "aws_amplify_branch" "main_branch" {
  app_id      = aws_amplify_app.plaid_app.id
  branch_name = var.branch_name
  
  enable_auto_build = true
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

# API Gateway Resource (Transactions)
resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  path_part   = "transactions"
}

# Lambda Function
resource "aws_lambda_function" "transaction_handler" {
  function_name    = "transaction_handler"
  role             = aws_iam_role.lambda_exec.arn
  runtime         = "python3.8"
  handler         = "lambda_function.lambda_handler"
  filename        = "lambda_API.zip"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.transactions.name
    }
  }
}

# Attach necessary policies
resource "aws_iam_policy_attachment" "lambda_execution" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API Gateway Integration with Lambda
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

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transaction_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.finance_api.execution_arn}/*/*"
}
