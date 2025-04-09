resource "aws_iam_role" "lex_service_role" {
  name = "LexServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lex.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lex_policy" {
  name = "LexServicePolicy"
  role = aws_iam_role.lex_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"  # You can scope this to your specific Lambda ARN for security
      }
    ]
  })
}


resource "aws_lexv2models_bot" "finance_assistant" {
  name                     = "financeAssistant"
  //role_arn                 = var.lex_role_arn
  role_arn = aws_iam_role.lex_service_role.arn
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  description                 = "Lex V2 bot for finance tracking"

  # Removed test_bot_alias block as it is not valid here
}

resource "null_resource" "create_lex_alias" {
  provisioner "local-exec" {
    command = <<EOT
    aws lexv2-models create-bot-alias \
      --bot-id ${aws_lexv2models_bot.finance_assistant.id} \
      --bot-alias-name "financeAssistantAlias" \
      --bot-version "DRAFT" \
      --bot-alias-locale-settings '{"en_US":{"enabled":true}}'
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

# resource "aws_lexv2models_bot_alias" "finance_assistant_alias" {
#   bot_id      = aws_lexv2models_bot.finance_assistant.id
#   bot_alias_name = "testAlias"
#   bot_version = "DRAFT"

#   bot_alias_locale_settings = {
#     "en_US" = {
#       enabled = true
#     }
#   }
# }

resource "aws_lexv2models_bot_locale" "english_locale" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  locale_id   = "en_US"
  description = "English (US) locale for Finance Assistant"
  n_lu_intent_confidence_threshold = 0.4
  bot_version                      = "DRAFT"

  voice_settings {
    voice_id = "Joanna"
  }

  depends_on = [aws_lexv2models_bot.finance_assistant]
}

# resource "aws_lexv2models_intent" "get_transactions_intent" {
#   name        = "GetTransactions"
#   bot_id      = aws_lexv2models_bot.finance_assistant.id
#   bot_version = "DRAFT"
#   locale_id   = "en_US"


#   sample_utterances {
#     utterance = "Show me my recent transactions"
#   }

#   sample_utterances {
#     utterance = "What did I spend last week?"
#   }

#   fulfillment_code_hook {
#     enabled = true
#   }

#   depends_on = [
#     aws_lexv2models_bot_locale.english_locale
#   ]
# }
