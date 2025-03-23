import json
import boto3
import os
from uuid import uuid4
from plaid import Client
from plaid.api import plaid_api
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.products import Products
from plaid.model.country_code import CountryCode
from plaid.model.user import LinkTokenCreateRequestUser
from plaid.configuration import Configuration
from plaid.api_client import ApiClient

# Initialize DynamoDB
dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)

# Plaid environment variables
PLAID_CLIENT_ID = os.environ["PLAID_CLIENT_ID"]
PLAID_SECRET = os.environ["PLAID_SECRET"]
PLAID_ENV = os.environ["PLAID_ENVIRONMENT"]

# Configure Plaid client
configuration = Configuration(
    host=f"https://{PLAID_ENV}.plaid.com",
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET
    }
)
api_client = ApiClient(configuration)
plaid_client = plaid_api.PlaidApi(api_client)

def lambda_handler(event, context):
    try:
        path = event.get("resource") or event.get("path")  # handles both test and live Lambda routes

        # 👇 Handle Plaid link_token creation
        if path == "/create_link_token":
            request = LinkTokenCreateRequest(
                user=LinkTokenCreateRequestUser(client_user_id=str(uuid4())),
                client_name="FiscAI",
                products=[Products("auth")],
                country_codes=[CountryCode("US")],
                language="en",
            )
            response = plaid_client.link_token_create(request)
            return {
                "statusCode": 200,
                "body": json.dumps({"link_token": response.link_token})
            }

        # 👇 Handle transaction save to DynamoDB
        if event["httpMethod"] == "POST" and path == "/transactions":
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
                "body": json.dumps({"message": "Transaction saved", "transaction_id": transaction_id})
            }

        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Route not found"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
