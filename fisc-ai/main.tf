# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    bucket  = "dd9098-fiscai-tf-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "receipt_bucket" {
  bucket        = "${var.environment}-frontend-receipts-${random_id.bucket_suffix.hex}" # Unique name
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "amplify_role" {
  name = "amplify-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_policy_attachment" "amplify_full_access" {
  name       = "amplify-full-access"
  roles      = [aws_iam_role.amplify_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# AWS Amplify App (With Plaid API Integration)
resource "aws_amplify_app" "plaid_app" {
  name        = var.app_name
  repository  = var.repo_url
  oauth_token = var.github_token # GitHub OAuth token for Amplify
  platform    = "WEB"
  # enable_auto_branch_creation = true
  auto_branch_creation_config {
    enable_auto_build           = true
    enable_pull_request_preview = false
    framework                   = "React"
    stage                       = "PRODUCTION"
  }
  enable_branch_auto_deletion = true
  environment_variables = {
    REACT_APP_ENV       = "production"
    REACT_APP_PLAID_ENV = var.plaid_environment
    # REACT_APP_API_URL can be injected after deploy via GitHub Actions
  }

  iam_service_role_arn = aws_iam_role.amplify_role.arn

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
  - appRoot: fisc-ai/backend/python
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
  stage             = "PRODUCTION"
  environment_variables = {
    REACT_APP_ENV       = "production"
    REACT_APP_PLAID_ENV = var.plaid_environment
  }
}

# DynamoDB Table for Transactions
resource "aws_dynamodb_table" "transactions" {
  name         = "transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "transaction_id"

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

# Lambda Function for Transaction Handling
resource "aws_lambda_function" "transaction_handler" {
  function_name = "transaction_handler"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "./build/lambda_API.zip"

  environment {
    variables = {
      DYNAMODB_TABLE    = aws_dynamodb_table.transactions.name
      PLAID_CLIENT_ID   = var.plaid_client_id
      PLAID_SECRET      = var.plaid_secret_key
      PLAID_ENVIRONMENT = var.plaid_environment
    }
  }
}

# Attach necessary policies
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_exec.name
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

# Package Lambda function code using archive_file data sources
data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_dir  = "./backend/api" # Relative path from main.tf to the API code folder
  output_path = "./build/api_function.zip"
}

data "archive_file" "webhook_processor_zip" {
  type        = "zip"
  source_dir  = "./backend/webhook_processor" # Relative path to the webhook processor folder
  output_path = "./build/webhook_processor.zip"
}

data "archive_file" "batch_writer_zip" {
  type        = "zip"
  source_dir  = "./backend/batch_writer" # Relative path to the batch writer folder
  output_path = "./build/batch_writer.zip"
}

# DynamoDB Table to store Plaid data
resource "aws_dynamodb_table" "plaid_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  attribute {
    name = "gsi1pk"
    type = "S"
  }
  attribute {
    name = "gsi1sk"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "gsi1pk"
    range_key       = "gsi1sk"
    projection_type = "ALL"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  ttl {
    attribute_name = "expire_at"
    enabled        = true
  }

  tags = {
    Environment = var.environment
  }
}

# SQS Queue for Webhook events
resource "aws_sqs_queue" "webhook_queue" {
  name                        = var.webhook_queue_name
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0
  message_retention_seconds   = 1209600
  receive_wait_time_seconds   = 20
  visibility_timeout_seconds  = 180

  tags = {
    Environment = var.environment
  }
}

# SQS Queue for Batch Writer
resource "aws_sqs_queue" "write_queue" {
  name                        = var.write_queue_name
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0
  message_retention_seconds   = 1209600
  receive_wait_time_seconds   = 20
  visibility_timeout_seconds  = 180

  tags = {
    Environment = var.environment
  }
}

# Secrets Manager Secret for Plaid credentials
resource "aws_secretsmanager_secret" "plaid_credential" {
  name        = "plaid/${var.plaid_environment}/credentials-${random_id.bucket_suffix.hex}"
  description = "Plaid credentials for ${var.plaid_environment} environment"

  tags = {
    Environment = var.environment
  }
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret_version" "plaid_credential_version" {
  secret_id = aws_secretsmanager_secret.plaid_credential.id
  secret_string = jsonencode({
    client_id     = var.plaid_client_id,
    client_secret = var.plaid_secret_key,
    endpoint      = "https://${var.plaid_environment}.plaid.com"
  })
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function for the API
resource "aws_lambda_function" "api_function" {
  function_name    = "${var.environment}-api-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.api_lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.api_lambda_zip.output_path)

  environment {
    variables = {
      ENVIRONMENT       = var.environment
      TABLE_NAME        = var.table_name
      PLAID_SECRET_ARN  = aws_secretsmanager_secret.plaid_credential.arn
      WEBHOOK_QUEUE_URL = aws_sqs_queue.webhook_queue.id
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Lambda function for Webhook Processor
resource "aws_lambda_function" "webhook_processor" {
  function_name    = "${var.environment}-webhook-processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.webhook_processor_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.webhook_processor_zip.output_path)

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      QUEUE_URL        = aws_sqs_queue.write_queue.id
      PLAID_SECRET_ARN = aws_secretsmanager_secret.plaid_credential.arn
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Lambda function for Batch Writer
resource "aws_lambda_function" "batch_writer" {
  function_name    = "${var.environment}-batch-writer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler.handler" # Adjust if your handler differs
  runtime          = "python3.9"
  filename         = data.archive_file.batch_writer_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.batch_writer_zip.output_path)

  environment {
    variables = {
      POWERTOOLS_SERVICE_NAME = "batch_writer"
    }
  }

  tags = {
    Environment = var.environment
  }
}
