resource "aws_lex_intent" "greet_intent" {
  name              = "GreetIntent"
  sample_utterances = ["Hi", "Hello", "Hey"]

  conclusion_statement {
    message {
      content_type = "PlainText"
      content      = "Hello! How can I help you today?"
    }
  }

  fulfillment_activity {
    type = "ReturnIntent"  # This just ends the intent with the response, no Lambda needed
  }
}


resource "aws_lex_bot" "greeting_bot" {
  name             = "GreetingBot"
  locale           = "en-US"
  child_directed   = false
  voice_id         = "Joanna"
  process_behavior = "BUILD"

  intent {
    intent_name    = aws_lex_intent.greet_intent.name
    intent_version = "$LATEST"
  }

  abort_statement {
    message {
      content_type = "PlainText"
      content      = "Sorry, I couldn't understand that."
    }
  }

  clarification_prompt {
    max_attempts = 2

    message {
      content_type = "PlainText"
      content      = "Can you please repeat that?"
    }
  }

  idle_session_ttl_in_seconds = 300
}



resource "aws_iam_role" "lex_execution_role" {
  name = "LexV1ExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lex.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lex_policy_attach" {
  role       = aws_iam_role.lex_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonLexFullAccess"
}

resource "aws_lex_bot_alias" "greeting_alias" {
  name   = "live"
  bot_name = aws_lex_bot.greeting_bot.name
  bot_version = "$LATEST"
}


