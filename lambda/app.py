import json
import uuid
import os
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
TABLE_NAME = os.environ.get("TABLE_NAME")
ENV = os.environ.get("ENV", "staging")

if not TABLE_NAME:
    raise RuntimeError("TABLE_NAME environment variable is not set")

# Initialize DynamoDB client (outside handler for reuse)
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    logger.info(f"Request received: {json.dumps(event)}")

    item = {
        "id": str(uuid.uuid4()),
        "request": event,
        "env": ENV
    }

    try:
        table.put_item(Item=item)
        logger.info(f"Item saved to DynamoDB: {item['id']}")
    except Exception as e:
        logger.exception("Error saving to DynamoDB")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "status": "error",
                "message": "Failed to save request."
            })
        }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "status": "healthy",
            "message": "Request processed and saved.",
            "id": item["id"]
        })
    }
