#!/usr/bin/env python
# -*- coding: utf-8 -*-

from typing import Dict, Any, List

from aws_lambda_powertools import Logger, Metrics
from aws_lambda_powertools.metrics import MetricUnit
import plaid
from plaid.model.categories_get_request import CategoriesGetRequest
from plaid.api import plaid_api

from app import utils, constants
from app.products import AbstractProduct

__all__ = ["Categories"]

logger = Logger(child=True)
metrics = Metrics()


class Categories(AbstractProduct):
    def build_message(self, category: Dict[str, Any]) -> Dict[str, Any]:
        """
        Build an SQS message from a Plaid Category object.
        """
        message = {
            "DelaySeconds": 0,
            "Id": utils.generate_id(),
            "MessageAttributes": {
                "CategoryId": {
                    "StringValue": category["category_id"],
                    "DataType": "String",
                },
                "EventName": {
                    "StringValue": "INSERT",
                    "DataType": "String",
                },
            },
        }

        # Build the message body including metadata for DynamoDB
        body = category.copy()
        body["pk"] = "CATEGORIES"
        body["sk"] = f"CATEGORY#{category['category_id']}"
        body["plaid_type"] = "Category"
        body["updated_at"] = utils.now_iso8601()
        message["MessageBody"] = utils.json_dumps(body)

        return message

    def sync(self) -> None:
        """
        Retrieve categories from Plaid and send them as messages to SQS.
        """
        logger.debug("Begin categories get")
        metrics.add_metric(name="PlaidCategoriesGetRequest", unit=MetricUnit.Count, value=1)

        # Construct the request to fetch categories
        request = CategoriesGetRequest()

        try:
            response = self.client.categories_get(request)
        except plaid.ApiException:
            logger.exception("Failed to call categories get")
            raise

        # Extract the list of categories from the response
        categories: List[Dict[str, Any]] = response.categories

        messages = []
        if categories:
            for category in categories:
                messages.append(self.build_message(category))
            # Use the inherited send_messages method to dispatch messages to SQS
            self.send_messages(messages)

        logger.debug("End categories get")