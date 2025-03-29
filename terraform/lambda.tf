# Lambda Function
resource "aws_lambda_function" "transaction_handler" {
  function_name = "transaction_handle"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.11"
  timeout       = 30
  handler       = "create_transaction.handler"
  filename      = "transaction.zip"
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

resource "aws_lambda_function" "access_token_handler" {
  function_name = "access_token_handler"
  filename      = "access_token.zip"  # Update with your zip location
  handler       = "access_token.handler"
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

resource "aws_lambda_function" "linked_token_handler" {
  function_name = "linked_token_handler"
  filename      = "linked_token.zip"  # Update with your zip location
  handler       = "linked_token.handler"
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