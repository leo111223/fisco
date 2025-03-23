variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "table_name" {
  description = "DynamoDB table name for storing Plaid data"
  default     = "PlaidTable"
}

variable "webhook_queue_name" {
  description = "Name of the SQS FIFO queue for webhook events"
  default     = "WebhookQueue.fifo"
}

variable "write_queue_name" {
  description = "Name of the SQS FIFO queue for batch writing"
  default     = "WriteQueue.fifo"
}

variable "plaid_client_id" {
  description = "Plaid Client ID"
  type        = string
}

variable "plaid_secret_key" {
  description = "Plaid Secret Key"
  type        = string
  sensitive   = true
}

variable "plaid_environment" {
  description = "Plaid environment (sandbox, development, production)"
  default     = "sandbox"
}
