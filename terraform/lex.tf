resource "aws_lexv2_bot" "lex_bot" {
  name         = "MyLexBot"
  role_arn     = aws_iam_role.lex_role.arn
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  # ... more config ...
}

resource "aws_lexv2_bot_alias" "lex_alias" {
  bot_id      = aws_lexv2_bot.lex_bot.id
  name        = "LiveAlias"
  description = "Alias for production"
  bot_version = "$LATEST"
}

resource "aws_iam_role" "lex_role" {
  name = "lex_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lex.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lex_logging" {
  name       = "attach-lex-logging"
  roles      = [aws_iam_role.lex_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonLexFullAccess"
}