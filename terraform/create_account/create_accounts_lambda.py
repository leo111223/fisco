import json
import os
import plaid
import boto3
from decimal import Decimal
from plaid.api.plaid_api import PlaidApi
from plaid.model.accounts_get_request import AccountsGetRequest
from plaid.exceptions import ApiException
from plaid import ApiClient, Configuration
from botocore.exceptions import ClientError

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
ACCOUNTS_TABLE_NAME = 'Accounts'

# Plaid API credentials
PLAID_CLIENT_ID = "679dd136d378b10023942d78"
PLAID_SECRET = "959c6a0ea2fd1deb626d707ca00d4f"

# Plaid environment configuration
configuration = Configuration(
    host="https://sandbox.plaid.com",
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
    }
)
api_client = ApiClient(configuration)
client = PlaidApi(api_client)

def create_accounts_table():
    try:
        table = dynamodb.create_table(
            TableName=ACCOUNTS_TABLE_NAME,
            KeySchema=[
                {
                    'AttributeName': 'user_id',
                    'KeyType': 'HASH'  # Partition key
                },
                {
                    'AttributeName': 'account_id',
                    'KeyType': 'RANGE'  # Sort key
                }
            ],
            AttributeDefinitions=[
                {
                    'AttributeName': 'user_id',
                    'AttributeType': 'S'
                },
                {
                    'AttributeName': 'account_id',
                    'AttributeType': 'S'
                }
            ],
            BillingMode='PAY_PER_REQUEST'
        )
        # Wait until the table exists
        table.meta.client.get_waiter('table_exists').wait(TableName=ACCOUNTS_TABLE_NAME)
        return table
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceInUseException':
            # Table already exists, return the existing table
            return dynamodb.Table(ACCOUNTS_TABLE_NAME)
        raise e

def convert_floats_to_decimals(obj):
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats_to_decimals(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats_to_decimals(i) for i in obj]
    return obj

def lambda_handler(event, context):
    try:
        # Parse the access_token and user_id from query parameters
        query_params = event.get("queryStringParameters", {})
        access_token = query_params.get("access_token")
        user_id = query_params.get("user_id")

        if not access_token or not user_id:
            return {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization"
                },
                "body": json.dumps({"error": "Missing access_token or user_id in query parameters"})
            }

        # Ensure table exists
        accounts_table = create_accounts_table()

        # Create the request to Plaid
        request = AccountsGetRequest(access_token=access_token)
        response = client.accounts_get(request)
        
        # Convert response to dictionary and convert floats to decimals
        accounts_data = response.to_dict()
        accounts_data = convert_floats_to_decimals(accounts_data)
        
        # Store accounts in DynamoDB
        with accounts_table.batch_writer() as batch:
            for account in accounts_data.get('accounts', []):
                # Add user_id to the account data
                account['user_id'] = user_id
                # Store the account
                batch.put_item(Item=account)

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            "body": json.dumps({
                "message": "Accounts stored successfully",
                "accounts": accounts_data
            }, default=str)  # Use default=str to handle Decimal serialization
        }

    except ApiException as e:
        # Handle Plaid API errors
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            "body": json.dumps({
                "error": "Plaid API Error",
                "details": json.loads(e.body)
            })
        }
    except Exception as e:
        # Catch any other errors
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            },
            "body": json.dumps({
                "error": "Internal Server Error",
                "details": str(e)
            })
        }
