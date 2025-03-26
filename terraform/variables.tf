variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Amplify App Name"
}

variable "repo_url" {
  description = "GitHub Repository URL"
}

variable "github_token" {
  description = "GitHub OAuth Token"
  type = string
  sensitive   = true
}

# variable "api_url" {
#   description = "API Base URL for the React App"
# }

variable "branch_name" {
  description = "Git Branch Name"
  default     = "main"
}

variable "plaid_client_id" {
  description = "Plaid API Client ID"
  sensitive   = true
}

variable "plaid_secret" {
  description = "Plaid API Secret Key"
  sensitive   = true
}

variable "plaid_environment" {
  description = "Plaid Environment (sandbox, development, production)"
  default     = "sandbox"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "transaction_handler"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "transactions"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)"
  type        = string
  default     = "test"
}
