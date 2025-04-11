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
            max_length         = 5
          }
        }

        text_input_specification {
          start_timeout_ms = 30000
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
            max_length         = 5
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
