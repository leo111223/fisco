#!/bin/bash

# Make sure terraform is initialized
cd terraform || exit
terraform init -input=false > /dev/null

# Capture output
API_URL=$(terraform output -raw api_url)

# Write to .env
echo "VITE_API_BASE_URL=$API_URL" > ../fisc-ai/frontend/.env

echo " .env updated with: $API_URL"
