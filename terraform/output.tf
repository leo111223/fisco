output "amplify_app_url" {
  value = "https://${aws_amplify_branch.main_branch.branch_name}.${aws_amplify_app.plaid_app.default_domain}"
  description = "URL to access the deployed Amplify app"
}


output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.finance_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
  description = "URL to access the deployed API Gateway"
}

output "s3_bucket" {
  value = aws_s3_bucket.receipt_bucket.id
}

output "lex_bot_id" {
  value = aws_lexv2_bot.finance_assistant.id
}

output "lex_bot_alias_id" {
  value = aws_lexv2_bot_alias.finance_assistant_alias.id
}

