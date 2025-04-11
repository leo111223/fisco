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
resource "null_resource" "create_lex_alias" {
  triggers = {
    bot_id = aws_lexv2models_bot.finance_assistant.id
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
      set -ex

      VERSION=$(aws lexv2-models create-bot-version \
        --bot-id ${self.triggers.bot_id} \
        --bot-version-locale-specification '{"en_US":{"sourceBotVersion":"DRAFT"}}' \
        --query 'botVersion' \
        --output text)

      if [ -z "$VERSION" ]; then
        echo "❌ Failed to retrieve bot version."
        exit 1
      fi

      echo "✅ Published Lex bot version: $VERSION"

      sleep 10

      aws lexv2-models create-bot-alias \
        --bot-id ${self.triggers.bot_id} \
        --bot-alias-name "financeAssistantAlias" \
        --bot-version "$VERSION" \
        --bot-alias-locale-settings '{"en_US":{"enabled":true}}'

      echo "✅ Lex alias created for version $VERSION"
    EOT
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "🔄 Looking up alias ID for deletion..."

      ALIAS_ID=$(aws lexv2-models list-bot-aliases \
        --bot-id ${self.triggers.bot_id} \
        --query "botAliasSummaries[?botAliasName=='financeAssistantAlias'].botAliasId" \
        --output text)

      if [ -z "$ALIAS_ID" ]; then
        echo "⚠️ Alias not found, nothing to delete."
        exit 0
      fi

      echo "❌ Deleting Lex alias ID $ALIAS_ID"
      aws lexv2-models delete-bot-alias \
        --bot-id ${self.triggers.bot_id} \
        --bot-alias-id $ALIAS_ID
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}
