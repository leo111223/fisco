output "api_function_arn" {
  description = "ARN of the API Lambda function"
  value       = aws_lambda_function.api_function.arn
}

output "webhook_queue_url" {
  description = "URL of the Webhook SQS queue"
  value       = aws_sqs_queue.webhook_queue.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.plaid_table.name
}
