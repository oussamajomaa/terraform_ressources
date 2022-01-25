import boto3
import os

# instructie le service rekogniton
client=boto3.client('rekognition',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])

bucket_name = "terega-prisesdevues-test"

collection_id = "terega-face-collection"
                    
s3 = boto3.resource('s3',
                    region_name=os.environ["region"],
                    aws_access_key_id=os.environ["access_key"],
                    aws_secret_access_key=os.environ["secret_key"])

bucket = s3.Bucket(bucket_name)

response = []
                    
def lambda_handler(event, context):
    
    for file in s3.Bucket(bucket_name).objects.all():
        split_photo= file.key.split('.')
        ex_image_id = split_photo[0]
        client.index_faces(CollectionId=collection_id,
                                Image={'S3Object':{'Bucket':bucket_name,'Name':file.key}},
                                ExternalImageId=ex_image_id,
                                MaxFaces=4,
                                QualityFilter="AUTO",
                                DetectionAttributes=['ALL'])
        response.append(ex_image_id)
        
    bucket.objects.all().delete()

    return response 


