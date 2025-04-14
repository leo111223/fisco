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
            value = "Is this what you meant?"
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

#transaction intent
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

  # This part links the slot to the intent
  # slot_priority {
  #   priority = 1
  #   slot_id  = aws_lexv2models_slot.number_of_transactions.slot_id
  # }
}



# resource "aws_lexv2models_slot" "number_of_transactions" {
#   name         = "NumberOfTransactions"
#   bot_id       = aws_lexv2models_bot.finance_assistant.id
#   bot_version  = "DRAFT"
#   locale_id    = "en_US"
#   intent_id    = aws_lexv2models_intent.get_recent_transactions.intent_id
#   //aws_lexv2models_intent.get_recent_transactions.id
  
  
#   slot_type_id = aws_lexv2models_slot_type.transaction_count_type.slot_type_id
#   value_elicitation_setting {
#     slot_constraint = "Optional"

#     prompt_specification {
#       max_retries = 1
#       allow_interrupt = true
#       message_group {
#         message {
#           plain_text_message {
#             value = "How many recent transactions would you like to see?"
#           }
#         }
#       }
#     }

#     default_value_specification {
#       default_value_list {
#         default_value = "5"
#       }
#     }
#   }
# }

# resource "aws_lexv2models_slot_type" "transaction_count_type" {
#   name         = "TransactionCountType"
#   description  = "Number of recent transactions to fetch"
#   bot_id = aws_lexv2models_bot.finance_assistant.id
#   bot_version   = "DRAFT"
#   locale_id     = "en_US"

#   value_selection_setting {
#     resolution_strategy = "OriginalValue"
#   }
#   slot_type_values {
#     sample_value {
#       value = "5"
#     }
#   }
#   slot_type_values {
#     sample_value {
#       value = "10"
#     }
#   }
#   slot_type_values {
#     sample_value {
#       value = "3"
#     }
#   }
# }

