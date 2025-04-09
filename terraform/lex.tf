
resource "aws_iam_role" "lex_service_role" {
  name = "lex_service_role"
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

resource "aws_lexv2_bot" "finance_assistant" {
  name                     = "FinanceAssistant"
  role_arn                 = aws_iam_role.lex_service_role.arn
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  bot_locale {
    locale_id        = "en_US"
    nlu_confidence_threshold = 0.4
    voice_settings {
      voice_id = "Joanna"
    }
  }
}

resource "aws_lexv2_bot_alias" "finance_assistant_alias" {
  name        = "live"
  bot_id      = aws_lexv2_bot.finance_assistant.id
  bot_version = "DRAFT"
}


resource "aws_lexv2_intent" "get_budget_advice" {
  name       = "GetBudgetAdviceIntent"
  bot_id     = aws_lexv2_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id  = "en_US"

  sample_utterances {
    utterance = "How is my spending this month?"
  }
  sample_utterances {
    utterance = "Can you help me budget?"
  }
  sample_utterances {
    utterance = "What should I spend less on?"
  }

  dialog_code_hook {
    enabled = true
  }

  fulfillment_code_hook {
    enabled = true
  }
}


resource "aws_lexv2_intent" "greeting_intent" {
  name       = "GreetingIntent"
  bot_id     = aws_lexv2_bot.finance_assistant.id
  bot_version = "DRAFT"
  locale_id  = "en_US"

  sample_utterances {
    utterance = "Hello"
  }
  sample_utterances {
    utterance = "Hi there"
  }
  sample_utterances {
    utterance = "How are you doing?"
  }
  sample_utterances {
    utterance = "What's up?"
  }
  sample_utterances {
    utterance = "Hey"
  }
  sample_utterances {
    utterance = "What can I help you with?"
  }

  fulfillment_activity {
    type = "CodeHook"
  }
}