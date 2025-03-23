import json
import boto3
import os
from uuid import uuid4

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])
        transaction_id = str(uuid4())  # Generate a unique transaction ID

        # Insert transaction into DynamoDB
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

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
