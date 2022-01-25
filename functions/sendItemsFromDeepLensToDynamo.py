import json
import boto3
import os
from datetime import timezone
import datetime
from dateutil.tz import tzlocal
from boto3.dynamodb.conditions import Key, Attr




client=boto3.client('rekognition',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])

bucket_name = "deeplens-face-rekognition-test"


collection_id = "terega-face-collection"
                    
s3 = boto3.resource('s3',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])

bucket = s3.Bucket(bucket_name)

dynamo_db = boto3.resource('dynamodb',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])
                    
        
table = dynamo_db.Table('rekognition-logs')
                    
def lambda_handler(event, context):
    faceMatches = []
    search_faces = []
    res = ""

    for file in s3.Bucket(bucket_name).objects.all():
        search_faces=client.search_faces_by_image(
            CollectionId=collection_id,
                Image={'S3Object':{'Bucket':bucket_name,'Name':file.key}},
            )

        for faceMatches in search_faces['FaceMatches']:
            
            dt = datetime.datetime.now(timezone.utc)
            utc_time = dt.replace(tzinfo=timezone.utc)
            utc_timestamp = utc_time.timestamp()

            res = table.scan(
                FilterExpression = Key('PartnerID').eq(faceMatches["Face"]["ExternalImageId"].replace('_','|')) & 
                Key('Date').between(int(utc_timestamp)-180,int(utc_timestamp)))
            if not(res['Count']):
                if "ExternalImageId" in faceMatches['Face']:
                    data = {
                        'PartnerID': faceMatches["Face"]["ExternalImageId"].replace('_','|'),
                        'Date' : int(utc_timestamp),
                        'Confidence':int(faceMatches["Face"]["Confidence"]),
                    }
                    table.put_item(Item=data)
                    s3.Object(bucket_name, file.key).delete()

    bucket.objects.all().delete()    

    list_faces=client.list_faces(CollectionId=collection_id)
       
    return list_faces
