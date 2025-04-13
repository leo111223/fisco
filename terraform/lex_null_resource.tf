resource "null_resource" "create_lex_alias" {
  triggers = {
    bot_id = aws_lexv2models_bot.finance_assistant.id
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
      set -x

      # Step 1: Build the DRAFT locale (if not already built)
      aws lexv2-models build-bot-locale \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US

      # Wait for build to complete
      echo "🕒 Waiting for locale build to finish..."
      until [[ $(aws lexv2-models describe-bot-locale \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --query 'botLocaleStatus' \
        --output text) == "Built" ]]; do
        sleep 5
      done

      # Step 2: Create a version from the DRAFT
      VERSION=$(aws lexv2-models create-bot-version \
        --bot-id ${self.triggers.bot_id} \
        --bot-version-locale-specification '{"en_US":{"sourceBotVersion":"DRAFT"}}' \
        --query 'botVersion' \
        --output text)

      echo "✅ Published Lex bot version: $VERSION"

      sleep 10

      # Step 3: Create or update alias and enable locale
      aws lexv2-models create-bot-alias \
        --bot-id ${self.triggers.bot_id} \
        --bot-alias-name "financeAssistantAlias" \
        --bot-version "$VERSION" \
        --bot-alias-locale-settings '{"en_US":{"enabled":true}}' || \
      aws lexv2-models update-bot-alias \
        --bot-id ${self.triggers.bot_id} \
        --bot-alias-id $(aws lexv2-models list-bot-aliases \
          --bot-id ${self.triggers.bot_id} \
          --query "botAliasSummaries[?botAliasName=='financeAssistantAlias'].botAliasId" \
          --output text) \
        --bot-alias-name "financeAssistantAlias" \
        --bot-version "$VERSION" \
        --bot-alias-locale-settings '{"en_US":{"enabled":true}}'

      echo "✅ Lex alias created and locale enabled."

      # Step 4: Output alias ID for use in Lambda
      ALIAS_ID=$(aws lexv2-models list-bot-aliases \
        --bot-id ${self.triggers.bot_id} \
        --query "botAliasSummaries[?botAliasName=='financeAssistantAlias'].botAliasId" \
        --output text)
      echo "ALIAS_ID resolved: $ALIAS_ID"
      echo "{\"lex_bot_alias_id\": \"$ALIAS_ID\"}" > lex_alias.json
      ls -la
        cat lex_alias.json
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}
