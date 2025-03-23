import json
import boto3
import os
from uuid import uuid4
from plaid import Client
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load environment variables
PLAID_CLIENT_ID = os.environ["PLAID_CLIENT_ID"]
PLAID_SECRET = os.environ["PLAID_SECRET"]
PLAID_ENV = os.environ["PLAID_ENVIRONMENT"]
REDIRECT_URI = os.environ.get("PLAID_REDIRECT_URI", "")
WEBHOOK_URI = os.environ.get("PLAID_WEBHOOK_URI", "")

# Initialize Plaid client
plaid_client = Client(
    client_id=PLAID_CLIENT_ID,
    secret=PLAID_SECRET,
    environment=PLAID_ENV,
)

# Initialize DynamoDB
dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)

# Default headers
HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",  # Adjust this in production
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type"
}

def lambda_handler(event, context):
    path = event.get("path", "")
    method = event.get("httpMethod", "")

    logger.info(f"Incoming request: {method} {path}")

    if method == "OPTIONS":
        return {"statusCode": 200, "headers": HEADERS, "body": json.dumps({})}

    if path == "/create_link_token" and method == "GET":
        return create_link_token()

    elif path == "/transactions" and method == "POST":
        return save_transaction(event)

    return {
        "statusCode": 404,
        "body": json.dumps({"message": "Route not found"}),
        "headers": HEADERS
    }

def create_link_token():
    try:
        response = plaid_client.LinkToken.create({
            "user": {"client_user_id": str(uuid4())},
            "client_name": "FiscAI",
            "products": ["auth", "transactions"],
            "country_codes": ["US"],
            "language": "en",
            "webhook": WEBHOOK_URI if WEBHOOK_URI else None,
            "redirect_uri": REDIRECT_URI if REDIRECT_URI else None
        })

        return {
            "statusCode": 200,
            "body": json.dumps({"link_token": response["link_token"]}),
            "headers": HEADERS
        }

    except Exception as e:
        logger.error(f"Error creating link token: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to create link token"}),
            "headers": HEADERS
        }

def save_transaction(event):
    try:
        body = json.loads(event["body"])
        transaction_id = str(uuid4())

        item = {
            "transaction_id": transaction_id,
            "user_id": body.get("user_id"),
            "amount": body.get("amount"),
            "category": body.get("category"),
            "timestamp": body.get("timestamp")
        }

        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Transaction saved successfully!",
                "transaction_id": transaction_id
            }),
            "headers": HEADERS
        }

    except Exception as e:
        logger.error(f"Error saving transaction: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to save transaction"}),
            "headers": HEADERS
        }
