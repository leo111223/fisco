import json
import boto3
import os
from uuid import uuid4
from plaid import Client

PLAID_CLIENT_ID = os.environ['PLAID_CLIENT_ID']
PLAID_SECRET = os.environ['PLAID_SECRET']
PLAID_ENV = os.environ['PLAID_ENVIRONMENT']

# Set up Plaid client
plaid_client = Client(
    client_id=PLAID_CLIENT_ID,
    secret=PLAID_SECRET,
    environment=PLAID_ENV,
)

dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    path = event.get("path", "")
    method = event.get("httpMethod", "")

    if path == "/create_link_token" and method == "GET":
        try:
            response = plaid_client.LinkToken.create({
                "user": {"client_user_id": str(uuid4())},
                "client_name": "FiscAI",
                "products": ["auth", "transactions"],
                "country_codes": ["US"],
                "language": "en",
                "webhook": "https://webhook.example.com",  # Optional
                "redirect_uri": "https://your-frontend-url.com",  # Optional
            })
            return {
                "statusCode": 200,
                "body": json.dumps({"link_token": response["link_token"]}),
                "headers": {"Content-Type": "application/json"}
            }
        except Exception as e:
            return {
                "statusCode": 500,
                "body": json.dumps({"error": str(e)})
            }

    # Existing transaction handler (POST /transactions)
    elif path == "/transactions" and method == "POST":
        try:
            body = json.loads(event["body"])
            transaction_id = str(uuid4())

            table.put_item(Item={
                "transaction_id": transaction_id,
                "user_id": body["user_id"],
                "amount": body["amount"],
                "category": body["category"],
                "timestamp": body["timestamp"]
            })

            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": "Transaction saved successfully!",
                    "transaction_id": transaction_id
                })
            }
        except Exception as e:
            return {
                "statusCode": 500,
                "body": json.dumps({"error": str(e)})
            }

    return {
        "statusCode": 404,
        "body": json.dumps({"message": "Route not found"})
    }
