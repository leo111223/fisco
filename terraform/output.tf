output "amplify_app_url" {
  value = "https://${aws_amplify_branch.main_branch.branch_name}.${aws_amplify_app.plaid_app.default_domain}"
  description = "URL to access the deployed Amplify app"
}


output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.finance_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
  description = "Root URL for API Gateway"
}

output "s3_bucket" {
  value = aws_s3_bucket.receipt_bucket.id
}


