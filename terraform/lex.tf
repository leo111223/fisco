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
  role_arn                 = aws_iam_role.lex_service_role.arn
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  description                 = "Lex V2 bot for finance tracking"
}

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
resource "aws_lexv2models_intent" "get_balance" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"
  name = "GetBalance"

  confirmation_setting {
    active = true

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Ordered"

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000

          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }

          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }



  fulfillment_code_hook {
    enabled = true
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}


# resource "aws_lexv2models_intent" "get_transactions_intent" {
#   bot_id      = aws_lexv2models_bot.finance_assistant.id
#   bot_version = "DRAFT"
#   locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id
#   name = "GetTransactions"

#   utterances = [
#     "Show me my recent transactions",
#     "What did I spend last week?"
#   ]

#   fulfillment_code_hook {
#     enabled = true
#   }

#   depends_on = [aws_lexv2models_bot_locale.english_locale]
# }
resource "null_resource" "create_lex_alias" {
  provisioner "local-exec" {
    command = <<EOT
      set -ex

      VERSION=$(aws lexv2-models create-bot-version \
        --bot-id ${aws_lexv2models_bot.finance_assistant.id} \
        --bot-version-locale-specification '{"en_US":{"sourceBotVersion":"DRAFT"}}' \
        --query 'botVersion' \
        --output text)

      if [ -z "$VERSION" ]; then
        echo "❌ Failed to retrieve bot version."
        exit 1
      fi

      echo "✅ Published Lex bot version: $VERSION"

      aws lexv2-models create-bot-alias \
        --bot-id ${aws_lexv2models_bot.finance_assistant.id} \
        --bot-alias-name "financeAssistantAlias" \
        --bot-version "$VERSION" \
        --bot-alias-locale-settings '{"en_US":{"enabled":true}}'

      echo "✅ Lex alias created for version $VERSION"
    EOT
    interpreter = ["bash", "-c"]
  }

  triggers = {
    bot_id = aws_lexv2models_bot.finance_assistant.id
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}



