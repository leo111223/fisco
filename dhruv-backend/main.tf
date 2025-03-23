provider "aws" {
    region = var.region
  }
  
  # Package Lambda function code using archive_file data sources
  data "archive_file" "api_lambda_zip" {
    type        = "zip"
    source_dir  = "./backend/api"  # Relative path from main.tf to the API code folder
    output_path = "./build/api_function.zip"
  }
  
  data "archive_file" "webhook_processor_zip" {
    type        = "zip"
    source_dir  = "./backend/webhook_processor"  # Relative path to the webhook processor folder
    output_path = "./build/webhook_processor.zip"
  }
  
  data "archive_file" "batch_writer_zip" {
    type        = "zip"
    source_dir  = "./backend/batch_writer"  # Relative path to the batch writer folder
    output_path = "./build/batch_writer.zip"
  }
  
  # DynamoDB Table to store Plaid data
  resource "aws_dynamodb_table" "plaid_table" {
    name           = var.table_name
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "pk"
    range_key      = "sk"
  
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
    name        = "plaid/${var.plaid_environment}/credentials"
    description = "Plaid credentials for ${var.plaid_environment} environment"
  
    tags = {
      Environment = var.environment
    }
  }
  
  resource "aws_secretsmanager_secret_version" "plaid_credential_version" {
    secret_id     = aws_secretsmanager_secret.plaid_credential.id
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
      Version   = "2012-10-17",
      Statement = [
        {
          Action    = "sts:AssumeRole",
          Principal = {
            Service = "lambda.amazonaws.com"
          },
          Effect    = "Allow",
          Sid       = ""
        }
      ]
    })
  
    tags = {
      Environment = var.environment
    }
  }
  
  # Attach basic Lambda execution policy
  resource "aws_iam_policy_attachment" "lambda_policy_attach" {
    name       = "${var.environment}-lambda-policy-attach"
    roles      = [aws_iam_role.lambda_role.name]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
  
  # Lambda function for the API
  resource "aws_lambda_function" "api_function" {
    function_name   = "${var.environment}-api-function"
    role            = aws_iam_role.lambda_role.arn
    handler         = "app.lambda_handler.handler"
    runtime         = "python3.9"
    filename        = data.archive_file.api_lambda_zip.output_path
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
    function_name   = "${var.environment}-webhook-processor"
    role            = aws_iam_role.lambda_role.arn
    handler         = "app.lambda_handler.handler"
    runtime         = "python3.9"
    filename        = data.archive_file.webhook_processor_zip.output_path
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
    function_name   = "${var.environment}-batch-writer"
    role            = aws_iam_role.lambda_role.arn
    handler         = "app.lambda_handler.handler"  # Adjust if your handler differs
    runtime         = "python3.9"
    filename        = data.archive_file.batch_writer_zip.output_path
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