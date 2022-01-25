import boto3
import os
import base64
import json

client = boto3.client('s3',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"]
                    )

def lambda_handler(event, context):
    
    body = base64.b64decode(event["content"])
    key = event["key"]
    
    client.put_object(
            Body=body,
            Bucket='terega-prisesdevues-test',
            Key=key
        )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        'body': json.dumps(event)
    }