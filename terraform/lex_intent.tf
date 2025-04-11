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
