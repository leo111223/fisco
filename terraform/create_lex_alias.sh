#!/bin/bash
set -e

BOT_ID=$1

# Create bot version and capture version number
VERSION=$(aws lexv2-models create-bot-version \
  --bot-id "$BOT_ID" \
  --locale-id en_US \
  --query 'botVersion' \
  --output text)

# Format JSON payload
JSON="{\"en_US\":{\"sourceBotVersion\":\"$VERSION\"}}"

# Create bot alias
aws lexv2-models create-bot-alias \
  --bot-id "$BOT_ID" \
  --bot-alias-name "financeAssistantAlias" \
  --bot-version-locale-specification "$JSON"
