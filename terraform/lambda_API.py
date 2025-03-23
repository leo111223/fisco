import json
import boto3
import os
from uuid import uuid4
from plaid import Client
from plaid.api import plaid_api
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.user import LinkTokenCreateRequestUser
from plaid.model.products import Products
from plaid.model.country_code import CountryCode
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.link_token_create_request_auth import LinkTokenCreateRequestAuth
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.link_token_create_request_payment_initiation import LinkTokenCreateRequestPaymentInitiation
from plaid.model.link_token_create_request_identity_verification import LinkTokenCreateRequestIdentityVerification

# Initialize Plaid client
PLAID_CLIENT_ID = os.environ["PLAID_CLIENT_ID"]
PLAID_SECRET = os.environ["PLAID_SECRET"]
PLAID_ENV = os.environ["PLAID_ENVIRONMENT"]

configuration = plaid.Configuration(
    host=plaid.Environment[PLAID_ENV],
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
    }
)
api_client = plaid.ApiClient(configuration)
plaid_client = plaid_api.PlaidApi(api_client)

# DynamoDB setup
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def lambda_handler(event, context):
    try:
        path = event.get("path", "")
        method = event.get("httpMethod")
        body = json.loads(event.get("body", "{}"))

        if path.endswith("/create_link_token"):
            request = LinkTokenCreateRequest(
                products=[Products.TRANSACTIONS],
                client_name="FiscAI",
                country_codes=[CountryCode.US],
                language='en',
                user=LinkTokenCreateRequestUser(client_user_id=str(uuid4()))
            )
            response = plaid_client.link_token_create(request)
            return {
                "statusCode": 200,
                "body": json.dumps({"link_token": response.link_token})
            }

        elif path.endswith("/set_access_token"):
            exchange_request = ItemPublicTokenExchangeRequest(
                public_token=body["public_token"]
            )
            exchange_response = plaid_client.item_public_token_exchange(exchange_request)
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "access_token": exchange_response.access_token,
                    "item_id": exchange_response.item_id
                })
            }

        elif path.endswith("/transactions"):
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
                "body": json.dumps({"message": "Transaction saved successfully!", "transaction_id": transaction_id})
            }

        else:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "Not Found"})
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
