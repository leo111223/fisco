# Intent definition for querying spending by category
resource "aws_lexv2models_intent" "query_spending_by_category" {
  name        = "QuerySpendingByCategory"
  description = "Allows users to ask about spending in specific categories and time periods"
  bot_id      = aws_lexv2models_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  # Sample utterances - making these diverse to handle various ways users might ask
  sample_utterance {
    utterance = "How much did I spend on {Category} {TimeFrame}"
  }
  sample_utterance {
    utterance = "What's my {Category} spending {TimeFrame}"
  }
  sample_utterance {
    utterance = "Show me my {Category} expenses {TimeFrame}"
  }
  sample_utterance {
    utterance = "Tell me about my {Category} purchases {TimeFrame}"
  }
  sample_utterance {
    utterance = "{Category} spending {TimeFrame}"
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
            value = "Is there anything else you'd like to know about your spending?"
          }
        }
      }
      allow_interrupt = true
    }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}

# Category slot
resource "aws_lexv2models_slot" "category_slot" {
  name         = "Category"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.spending_category_type.slot_type_id
  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 2  # This should match the number of retry specifications
      allow_interrupt = true

      message_group {
        message {
          plain_text_message {
            value = "Which spending category would you like to know about? For example: groceries, dining, entertainment, etc."
          }
        }
      }

      message_selection_strategy = "Random"

      # Initial prompt
      prompt_attempts_specification {
        map_block_key = "Initial"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # First retry
      prompt_attempts_specification {
        map_block_key = "Retry1"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }

      # Second retry - Add this block
      prompt_attempts_specification {
        map_block_key = "Retry2"
        allow_interrupt = true

        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }

        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            max_length_ms  = 15000
            end_timeout_ms = 640
          }
          dtmf_specification {
            max_length         = 20
            end_timeout_ms     = 5000
            deletion_character = "*"
            end_character      = "#"
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }
}

# Time frame slot
resource "aws_lexv2models_slot" "time_frame_slot" {
  name         = "TimeFrame"  # Changed name to be simpler
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.time_frame_type.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"
    
    # Use default settings instead of detailed prompt specifications
    default_value_specification {
      default_value_list {
        default_value = "this month"
      }
    }
  }
}
# Category slot type
# Category slot type
# Category slot type
resource "aws_lexv2models_slot_type" "spending_category_type" {
  name         = "SpendingCategoryType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Categories of spending"

  value_selection_setting {
    resolution_strategy = "TopResolution"  # Changed from ORIGINAL_VALUE to TOP_RESOLUTION
  }

  # Use slot_type_values instead of enumeration_value
  slot_type_values {
    sample_value { value = "groceries" }
    synonyms { value = "grocery" }
    synonyms { value = "supermarket" }
    synonyms { value = "food shopping" }
  }
  
  slot_type_values {
    sample_value { value = "dining" }
    synonyms { value = "restaurants" }
    synonyms { value = "eating out" }
    synonyms { value = "food" }
  }
  
  slot_type_values {
    sample_value { value = "entertainment" }
    synonyms { value = "fun" }
    synonyms { value = "movies" }
    synonyms{ value = "shows" }
  }
  
  slot_type_values {
    sample_value { value = "shopping" }
    synonyms { value = "retail" }
    synonyms { value = "clothes" }
    synonyms { value = "purchases" }
  }
  
  slot_type_values {
    sample_value { value = "transportation" }
    synonyms { value = "transit" }
    synonyms { value = "travel" }
    synonyms { value = "commute" }
  }
  
  slot_type_values {
    sample_value { value = "utilities" }
    synonyms { value = "bills" }
    synonyms { value = "electricity" }
    synonyms { value = "water" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}

# Time frame slot type
resource "aws_lexv2models_slot_type" "time_frame_type" {
  name         = "TimeFrameType"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  description  = "Time periods for queries"

  value_selection_setting {
    resolution_strategy = "TopResolution"  # Changed from ORIGINAL_VALUE to TOP_RESOLUTION
  }

  # Use slot_type_values instead of enumeration_value
  slot_type_values {
    sample_value { value = "today" }
    synonyms { value = "this day" }
  }
  
  slot_type_values {
    sample_value { value = "yesterday" }
  }
  
  slot_type_values {
    sample_value { value = "this week" }
    synonyms { value = "current week" }
  }
  
  slot_type_values {
    sample_value { value = "last week" }
    synonyms { value = "previous week" }
  }
  
  slot_type_values {
    sample_value { value = "this month" }
    synonyms { value = "current month" }
  }
  
  slot_type_values {
    sample_value { value = "last month" }
    synonyms { value = "previous month" }
  }
  
  slot_type_values {
    sample_value { value = "this year" }
    synonyms { value = "current year" }
  }
  
  slot_type_values {
    sample_value { value = "last year" }
    synonyms { value = "previous year" }
  }

  depends_on = [
    aws_lexv2models_bot_locale.english_locale
  ]
}
# The null resource to fix the slot priority circular dependency
resource "null_resource" "update_query_spending_by_category_slot_priorities" {
  triggers = {
    bot_id     = aws_lexv2models_bot.finance_assistant.id
    intent_id  = aws_lexv2models_intent.query_spending_by_category.id
    locale_id  = "en_US"
    slot_1     = "Category"
    slot_2     = "TimeFrame"
  }

  provisioner "local-exec" {
    command = <<EOT
      set -xe

      BOT_ID=${self.triggers.bot_id}
      INTENT_ID=${self.triggers.intent_id}
      LOCALE=${self.triggers.locale_id}
      SLOT_NAME_1=${self.triggers.slot_1}
      SLOT_NAME_2=${self.triggers.slot_2}

      # Get slot IDs by name
      SLOT_ID_1=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='$SLOT_NAME_1'].slotId" \
        --output text)

      SLOT_ID_2=$(aws lexv2-models list-slots \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --query "slotSummaries[?slotName=='$SLOT_NAME_2'].slotId" \
        --output text)

      echo "Slot IDs found: $SLOT_NAME_1=$SLOT_ID_1, $SLOT_NAME_2=$SLOT_ID_2"

      # Describe the intent and remove immutable fields
      aws lexv2-models describe-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID | \
        jq 'del(.creationDateTime, .lastUpdatedDateTime, .version, .name)' > intent_config.json

      # Add slot priorities
      jq --arg slot1 "$SLOT_ID_1" --arg slot2 "$SLOT_ID_2" \
        '.slotPriorities = [{"priority": 1, "slotId": $slot1}, {"priority": 2, "slotId": $slot2}]' \
        intent_config.json > updated_intent.json

      # Push the updated intent back
      aws lexv2-models update-intent \
        --bot-id $BOT_ID \
        --bot-version DRAFT \
        --locale-id $LOCALE \
        --intent-id $INTENT_ID \
        --cli-input-json file://updated_intent.json

      echo "✅ Slot priorities updated successfully for $INTENT_ID"
    EOT
  }
  depends_on = [
    aws_lexv2models_intent.query_spending_by_category,
    aws_lexv2models_slot.category_slot,
    aws_lexv2models_slot.time_frame_slot
  ]
}


