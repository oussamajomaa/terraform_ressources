import json
import boto3
import os

invokeLambda = boto3.client('lambda',
                            region_name=os.environ["region"],
                            aws_access_key_id=os.environ["access_key"],
                            aws_secret_access_key=os.environ["secret_key"])

client = boto3.client('rekognition',
                      region_name=os.environ["region"],
                      aws_access_key_id=os.environ["access_key"],
                      aws_secret_access_key=os.environ["secret_key"])


def lambda_handler(event, context):
    res_collection = client.list_collections()
    
    if not("terega-face-collection" in res_collection["CollectionIds"]):
        client.create_collection(CollectionId='terega-face-collection')
        
    return {
        'statusCode': 200,
        'headers': {
            # 'Access-Control-Allow-Headers':'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            # 'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            # 'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({'collection': res_collection})
    }