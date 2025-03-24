# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# Deployment environment (e.g., dev, test, prod)
variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)"
  type        = string
  default     = "test"
}

# DynamoDB table name for storing Plaid data
variable "table_name" {
  description = "The name of the DynamoDB table for Plaid data"
  type        = string
  default     = "PlaidTable"
}

# SQS Queue names (FIFO)
variable "webhook_queue_name" {
  description = "The name of the SQS FIFO queue for webhook events"
  type        = string
  default     = "WebhookQueue.fifo"
}

variable "write_queue_name" {
  description = "The name of the SQS FIFO queue for batch writing"
  type        = string
  default     = "WriteQueue.fifo"
}

# Plaid Credentials
variable "plaid_client_id" {
  description = "The Plaid client ID"
  type        = string
  default     = "67af9b69c8f2dc00237784ae"
}

variable "plaid_secret_key" {
  description = "The Plaid secret key"
  type        = string
  default     = "1182a4513455700a82fa5d2717af79"
}

variable "plaid_environment" {
  description = "The Plaid environment (sandbox, development, production)"
  type        = string
  default     = "sandbox"
}

# GitHub Repository and Amplify App Configuration
variable "repo_url" {
  description = "The URL of the GitHub repository for the Amplify app"
  type        = string
  default     = "https://github.com/leo111223/fisco.git"
}

variable "app_name" {
  description = "The name of the Amplify app"
  type        = string
  default     = "FiscAI"
}

variable "branch_name" {
  description = "The branch name for the Amplify app deployment"
  type        = string
  default     = "main"
}

# GitHub OAuth Token for Amplify
variable "github_token" {
  description = "The GitHub OAuth token for Amplify"
  type        = string
  sensitive   = true
}

# Lambda and DynamoDB Configuration
variable "lambda_function_name" {
  description = "The name of the Lambda function for transaction handling"
  type        = string
  default     = "transaction_handler"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for transactions"
  type        = string
  default     = "transactions"
}