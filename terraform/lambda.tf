# transaction handler
resource "aws_lambda_function" "transaction_handler" {
  function_name = "transaction_handle"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  timeout       = 30
  handler       = "create_transactions.lambda_handler"
  filename      = "transaction.zip"
 

  environment {
    variables = {
      DYNAMODB_TABLE     = aws_dynamodb_table.transactions.name
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

#access token handler
resource "aws_lambda_function" "access_token_handler" {
  function_name = "access_token_handler"
  filename      = "access_token.zip"  # Update with your zip location
  handler       = "access_token.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  environment {
    variables = {
      STAGE = "prod"
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

#linked token handler
resource "aws_lambda_function" "linked_token_handler" {
  function_name = "linked_token_handler"
  filename      = "linked_token.zip"  # Update with your zip location
  handler       = "lambda_link_token.handler"
  runtime       = "python3.11"  # or nodejs18.x, etc.
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  environment {
    variables = {
      STAGE = "prod"
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
    }
  }
}

# Lambda function
# NEEDS FOLLOWING:
# Textract DetectDocumentText permission
# S3 GetObject and PutObject permissions
# Trigger on S3 ObjectCreated
resource "aws_lambda_function" "textract_lambda" {
  function_name    = "textractProcessor"
  runtime         = "python3.9"
  handler         = "lambda_function.lambda_handler"
  role            = aws_iam_role.lambda_exec.arn
  timeout         = 30
  filename        = "textract.zip"
  environment {
    variables = {
      DEST_BUCKET = "fiscai-textract-output"
    }
  }
}

## new update

# Create Account Handler
resource "aws_lambda_function" "get_accounts_handler" {
  function_name = "get_accounts_handler"
  filename      = "create_account.zip"  # Update with the location of your deployment package
  handler       = "create_accounts_lambda.handler"  # Update with your handler function
  runtime       = "python3.11"  # Update with your preferred runtime
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30

  environment {
    variables = {
      PLAID_CLIENT_ID    = var.plaid_client_id
      PLAID_SECRET       = var.plaid_secret
      PLAID_ENVIRONMENT  = var.plaid_environment
      DYNAMODB_TABLE     = aws_dynamodb_table.accounts.name  # Example DynamoDB table for storing accounts
    }
  }
}

# Query Lex Handler
resource "aws_lambda_function" "query_lex_handler" {
  function_name = "query_lex_handler"
  filename      = "query_lex.zip"  # Update with the location of your deployment package
  handler       = "query_lex.lambda_handler"  # Update with your handler function
  runtime       = "python3.11"  # Update with your preferred runtime
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30

  environment {
    variables = {
      LEX_BOT_NAME    = var.lex_bot_name
      LEX_BOT_ALIAS   = var.lex_bot_alias
      AWS_REGION      = var.aws_region
    }
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


# Lambda Policy
resource "aws_iam_policy_attachment" "lambda_execution" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}