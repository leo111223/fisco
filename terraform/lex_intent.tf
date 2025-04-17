resource "aws_lexv2models_intent" "greeting_intent" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  name        = "GreetingIntent"
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  description = "Handles greetings like hello, hi, etc."

  sample_utterance {
    utterance = "hello"
  }
  sample_utterance {
    utterance = "hi"
  }
  sample_utterance {
    utterance = "hey"
  }

  confirmation_setting {
    active = true

    prompt_specification {
      message_selection_strategy = "Ordered"
      max_retries                = 1
      allow_interrupt            = true

      message_group {
        message {
          plain_text_message {
            value = "what can i help you?"
          }
        }
      }
    }
  }

  fulfillment_code_hook {
    enabled = false
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}

resource "aws_lexv2models_intent" "goodbye_intent" {
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = aws_lexv2models_bot_locale.english_locale.bot_version
  name        = "GoodbyeIntent"
  locale_id   = aws_lexv2models_bot_locale.english_locale.locale_id

  description = "Handles goodbyes like bye, see ya, etc."

  sample_utterance {
    utterance = "bye"
  }

  sample_utterance {
    utterance = "goodbye"
  }

  sample_utterance {
    utterance = "see you later"
  }

  confirmation_setting {
    active = true

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 1
      message_selection_strategy = "Ordered"

      message_group {
        message {
          plain_text_message {
            value = "Are you sure you want to end the conversation?"
          }
        }
      }
    }
  }

  fulfillment_code_hook {
    enabled = true
  }

  depends_on = [aws_lexv2models_bot_locale.english_locale]
}

# Intent definition without slot_priority
resource "aws_lexv2models_intent" "get_recent_transactions" {
  name        = "GetRecentTransactions"
  description = "Returns the user's most recent transactions"
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  sample_utterance {
    utterance = "Show me the last {NumberOfTransactions} transactions"
  }

  sample_utterance {
    utterance = "Get my latest {NumberOfTransactions} transactions"
  }

  sample_utterance {
    utterance = "What are my last {NumberOfTransactions} purchases?"
  }

  fulfillment_code_hook {
    enabled = true
  }

  closing_setting {
    active = true

    closing_response {
      message_group {
        message {
          plain_text_message {
            value = "Let me know if you need anything else!"
          }
        }
      }
      allow_interrupt = true
    }
  }
  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
  # No slot_priority block here
}

# Slot definition with intent_id reference
resource "aws_lexv2models_slot" "number_of_transactions" {
  name         = "NumberOfTransactions"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.get_recent_transactions.intent_id
  slot_type_id = aws_lexv2models_slot_type.transaction_count_type.slot_type_id

  # Rest of your slot configuration...
  value_elicitation_setting {
    slot_constraint = "Optional"
    # ...rest of your configuration
  }
}

# Add this null_resource to update the intent with the slot priority
resource "null_resource" "update_intent_slot_priority" {
  triggers = {
    bot_id     = aws_lexv2models_bot.finance_assistant.id
    intent_id  = aws_lexv2models_intent.get_recent_transactions.intent_id
    slot_id    = aws_lexv2models_slot.number_of_transactions.slot_id
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe
      
      # Get the current intent configuration and filter out metadata fields
      aws lexv2-models describe-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} | \
        jq 'del(.creationDateTime, .lastUpdatedDateTime, .version)' > intent_config.json
      
      # Add the slot priority to the configuration
      # First check if slotPriorities exists, if not create it
      if jq -e '.slotPriorities' intent_config.json > /dev/null; then
        # slotPriorities exists, append to it
        jq --arg slot_id "${self.triggers.slot_id}" '.slotPriorities += [{"priority": 1, "slotId": $slot_id}]' intent_config.json > updated_intent.json
      else
        # slotPriorities doesn't exist, create it
        jq --arg slot_id "${self.triggers.slot_id}" '.slotPriorities = [{"priority": 1, "slotId": $slot_id}]' intent_config.json > updated_intent.json
      fi
      
      # Update the intent with the new configuration
      aws lexv2-models update-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --cli-input-json file://updated_intent.json
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_lexv2models_intent.get_recent_transactions,
    aws_lexv2models_slot.number_of_transactions
  ]
}

resource "aws_lexv2models_slot_type" "transaction_count_type" {
  name         = "TransactionCountType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Number of recent transactions to fetch"

  value_selection_setting {
    resolution_strategy = "OriginalValue"
  }

  slot_type_values {
    sample_value { value = "3" }
  }
  slot_type_values {
    sample_value { value = "5" }
  }
  slot_type_values {
    sample_value { value = "10" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}
