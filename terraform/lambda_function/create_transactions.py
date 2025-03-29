import os
import json
from plaid.api.plaid_api import PlaidApi
from plaid.model.transactions_get_request import TransactionsGetRequest
from plaid.model.transactions_get_request_options import TransactionsGetRequestOptions
from plaid.configuration import Configuration
from plaid.api_client import ApiClient
from datetime import date

# Plaid API credentials
PLAID_CLIENT_ID = os.environ['PLAID_CLIENT_ID']
PLAID_SECRET = os.environ['PLAID_SECRET']
PLAID_ENV = os.environ['PLAID_ENVIRONMENT']
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

def lambda_handler(event, context):
    try:
        # Extract the access_token from the query string parameters
        access_token = event.get("queryStringParameters", {}).get("access_token")

        if not access_token:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing access_token in the request'})
            }

        # Define the date range for transactions
        start_date = date(2020, 1, 1)
        end_date = date(2021, 4, 1)

        # Fetch the first page of transactions
        request = TransactionsGetRequest(
            access_token=access_token,
            start_date=start_date,
            end_date=end_date,
            options=TransactionsGetRequestOptions(count=100)
        )
        response = client.transactions_get(request)
        response_dict = response.to_dict()
        transactions = response_dict.get('transactions', [])
        total_transactions = response_dict.get('total_transactions', 0)

        # Paginate through all transactions
        while len(transactions) < total_transactions:
            request = TransactionsGetRequest(
                access_token=access_token,
                start_date=start_date,
                end_date=end_date,
                options=TransactionsGetRequestOptions(
                    offset=len(transactions),
                    count=100
                )
            )
            response = client.transactions_get(request)
            response_dict = response.to_dict()
            transactions.extend(response_dict.get('transactions', []))

        # Return the transactions in the response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'transactions': transactions,
                'total_transactions': total_transactions
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

