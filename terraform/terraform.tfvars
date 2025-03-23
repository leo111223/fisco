# terraform.tfvars

aws_region = "us-east-1"

repo_url = "https://github.com/leo111223/fisco.git"
#repo_url = "https://github.com/SWEN-614-Spring-2025/term-project-team5-ledgermen.git"
app_name = "FiscAI"
#branch_name = "amplify_branch"
branch_name = "main"
# api_url = "https://api.example.com"

plaid_client_id  = "67ad2ec20245ff0021df5364"
plaid_secret     = "b87f4cfceb87f20dbdf89dc2602c2a"
plaid_environment = "sandbox"

lambda_function_name = "transaction_handler"
dynamodb_table_name  = "transactions"
