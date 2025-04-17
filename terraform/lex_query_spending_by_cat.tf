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
  name         = "TimeFrame"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.time_frame_type.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 2
      allow_interrupt = true

      message_group {
        message {
          plain_text_message {
            value = "For what time period? For example: this week, last month, in January, etc."
          }
        }
      }

      message_selection_strategy = "Random"

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
    }
  }
}

# Category slot type
resource "aws_lexv2models_slot" "category_slot" {
  name         = "SpendingCategory"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.spending_category_type.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 1
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
    }
  }
}

resource "aws_lexv2models_slot" "time_frame_slot" {
  name         = "SpendingTimeFrame"
  bot_id       = aws_lexv2models_bot.finance_assistant.id
  bot_version  = "DRAFT"
  locale_id    = "en_US"
  intent_id    = aws_lexv2models_intent.query_spending_by_category.intent_id
  slot_type_id = aws_lexv2models_slot_type.time_frame_type.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"
    
    prompt_specification {
      max_retries = 1
      allow_interrupt = true

      message_group {
        message {
          plain_text_message {
            value = "For what time period? For example: this week, last month, in January, etc."
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
    }
  }
}

# The null resource to fix the slot priority circular dependency
resource "null_resource" "update_spending_intent_slot_priorities" {
  triggers = {
    bot_id     = aws_lexv2models_bot.finance_assistant.id
    intent_id  = aws_lexv2models_intent.query_spending_by_category.intent_id
    category_slot_id = aws_lexv2models_slot.category_slot.slot_id
    time_frame_slot_id = aws_lexv2models_slot.time_frame_slot.slot_id
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
      
      # Add the slot priorities to the configuration
      jq --arg category_id "${self.triggers.category_slot_id}" \
         --arg timeframe_id "${self.triggers.time_frame_slot_id}" \
         '.slotPriorities = [
           {"priority": 1, "slotId": $category_id},
           {"priority": 2, "slotId": $timeframe_id}
         ]' intent_config.json > updated_intent.json
      
      # Update the intent with the new configuration
      aws lexv2-models update-intent \
        --bot-id ${self.triggers.bot_id} \
        --bot-version DRAFT \
        --locale-id en_US \
        --intent-id ${self.triggers.intent_id} \
        --cli-input-json file://updated_intent.json
        
      echo "✅ Successfully added slot priorities to QuerySpendingByCategory intent"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    aws_lexv2models_intent.query_spending_by_category,
    aws_lexv2models_slot.category_slot,
    aws_lexv2models_slot.time_frame_slot
  ]
}