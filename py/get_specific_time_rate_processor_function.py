import json

import boto3
from boto3.dynamodb.conditions import Key

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Rates')
    response = table.query(
        KeyConditionExpression=Key('timestamp').eq(event['timestamp'])
    )
    return response['Items']