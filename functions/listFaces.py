import json
import boto3
import os

client=boto3.client('rekognition',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])
                    

def lambda_handler(event, context):

    method = event['httpMethod']
    

    if method == 'GET':
        response = client.list_faces(CollectionId="terega-face-collection")
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({'collection': response['Faces']})
        }
    

    if method == 'DELETE':
        faceIds = event['multiValueQueryStringParameters']['id']
        response = client.delete_faces(
            CollectionId="terega-face-collection", 
            FaceIds = faceIds
        )
    
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({'response': response})
        }

