import os
import json
from plaid.api import plaid_api
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.products import Products
from plaid.model.country_code import CountryCode
from plaid.model.language import Language
from plaid import Configuration, ApiClient

def handler(event, context):
    try:
        # Load environment variables
        PLAID_CLIENT_ID = os.environ['PLAID_CLIENT_ID']
        PLAID_SECRET = os.environ['PLAID_SECRET']
        PLAID_ENV = os.environ['PLAID_ENV']

        # Set up Plaid configuration
        config = Configuration(
            host=f'https://{PLAID_ENV}.plaid.com',
            api_key={
                'clientId': PLAID_CLIENT_ID,
                'secret': PLAID_SECRET,
            }
        )

        api_client = ApiClient(configuration=config)
        client = plaid_api.PlaidApi(api_client)

        request = LinkTokenCreateRequest(
            user=LinkTokenCreateRequestUser(client_user_id='unique_user_id'),
            client_name='Finance Tracker App',
            products=[Products('transactions')],
            country_codes=[CountryCode('US')],
            language=Language('en'),
        )

        response = client.link_token_create(request)
        return {
            'statusCode': 200,
            'body': json.dumps({'link_token': response['link_token']})
        }

    except Exception as e:
        print("Error occurred:", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
