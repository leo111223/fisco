import json
import plaid
from plaid.api.plaid_api import PlaidApi
from plaid.model.sandbox_public_token_create_request import SandboxPublicTokenCreateRequest
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.transactions_get_request import TransactionsGetRequest
from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
from plaid.model.products import Products
from plaid.configuration import Configuration
from plaid.api_client import ApiClient
from datetime import datetime, timedelta

# Plaid API credentials
PLAID_CLIENT_ID = "679dd136d378b10023942d78"  # Replace with your actual client ID
PLAID_SECRET = "959c6a0ea2fd1deb626d707ca00d4f"        # Replace with your actual secret

# Plaid environment configuration
configuration = Configuration(
    host="https://sandbox.plaid.com",  # Use "https://production.plaid.com" for production
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
    }
)
api_client = ApiClient(configuration)
client = PlaidApi(api_client)

def lambda_handler(event, context):
    try:
        # Step 1: Create a sandbox public token
        # sandbox_request = SandboxPublicTokenCreateRequest(
        #     institution_id="ins_109508",  # Sandbox institution ID (e.g., Chase)
        #     initial_products=[Products("transactions")],  # Specify the product(s)
        # )
        # sandbox_response = client.sandbox_public_token_create(sandbox_request)
        # public_token = sandbox_response['public_token']

        # # Step 2: Exchange the public token for an access token
        # exchange_request = ItemPublicTokenExchangeRequest(public_token=public_token)
        # exchange_response = client.item_public_token_exchange(exchange_request)
        access_token = "link-sandbox-418ce4a6-0cad-4d3f-9ee2-6df46a0995ea"

        # Step 3: Fetch transactions using the access token
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=30)  # Fetch transactions for the last 30 days

        transactions_request = TransactionsGetRequest(
            access_token=access_token,
            start_date=start_date,
            end_date=end_date,
            options=TransactionsGetRequestOptions(
                count=10,  # Number of transactions to fetch
                offset=0    # Offset for pagination
            )
        )
        # transactions_response = client.transactions_get(transactions_request)
        # transactions = transactions_response['transactions']

        # Step 4: Return the transactions in the response
        return {
            'statusCode': 200,
            'body': json.dumps({
                # 'transactions': [transaction.to_dict() for transaction in transactions]
                'acess_token': access_token
            })
        }
    except Exception as e:
        # Handle exceptions and return an error response
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
