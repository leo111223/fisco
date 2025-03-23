# AWS Region
region = "us-east-1"

# Deployment environment (e.g., dev, prod)
environment = "test"

# DynamoDB table name for storing Plaid data
table_name = "PlaidTable"

# SQS Queue names (FIFO)
webhook_queue_name = "WebhookQueue.fifo"
write_queue_name   = "WriteQueue.fifo"

# Plaid Credentials
plaid_client_id   = "67af9b69c8f2dc00237784ae"
plaid_secret_key  = "1182a4513455700a82fa5d2717af79"
plaid_environment = "sandbox" # Options: sandbox, development, production
