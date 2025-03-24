# AWS Amplify App Outputs
output "amplify_app_id" {
  description = "The ID of the AWS Amplify app"
  value       = aws_amplify_app.plaid_app.id
}

output "amplify_app_default_domain" {
  description = "The default domain of the AWS Amplify app"
  value       = aws_amplify_app.plaid_app.default_domain
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.receipt_bucket.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.receipt_bucket.arn
}

# DynamoDB Table Outputs
output "dynamodb_transactions_table_name" {
  description = "The name of the DynamoDB table for transactions"
  value       = aws_dynamodb_table.transactions.name
}

output "dynamodb_plaid_table_name" {
  description = "The name of the DynamoDB table for Plaid data"
  value       = aws_dynamodb_table.plaid_table.name
}

# SQS Queue Outputs
output "webhook_queue_url" {
  description = "The URL of the SQS FIFO queue for webhook events"
  value       = aws_sqs_queue.webhook_queue.url
}

output "write_queue_url" {
  description = "The URL of the SQS FIFO queue for batch writing"
  value       = aws_sqs_queue.write_queue.url
}

# output "api_gateway_url" {       #api url
#   value = "${aws_apigatewayv2_api.my_api.api_endpoint}/${aws_apigatewayv2_stage.my_stage.name}"
# }
# Lambda Function Outputs
output "transaction_handler_lambda_arn" {
  description = "The ARN of the Lambda function for transaction handling"
  value       = aws_lambda_function.transaction_handler.arn
}

output "api_function_lambda_arn" {
  description = "The ARN of the Lambda function for the API"
  value       = aws_lambda_function.api_function.arn
}

output "webhook_processor_lambda_arn" {
  description = "The ARN of the Lambda function for webhook processing"
  value       = aws_lambda_function.webhook_processor.arn
}

output "batch_writer_lambda_arn" {
  description = "The ARN of the Lambda function for batch writing"
  value       = aws_lambda_function.batch_writer.arn
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.finance_api.id
}

output "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.finance_api.execution_arn
}

# Secrets Manager Outputs
output "plaid_secret_arn" {
  description = "The ARN of the Secrets Manager secret for Plaid credentials"
  value       = aws_secretsmanager_secret.plaid_credential.arn
}

# IAM Role Outputs
output "lambda_exec_role_arn" {
  description = "The ARN of the IAM role for Lambda execution"
  value       = aws_iam_role.lambda_exec.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role for Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}