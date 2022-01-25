
##############################################################################

# CREATE ZIP FILE FOR THE FUNCTION SEND ITEMS INTO DYNAMODB
data "archive_file" "sendItemsFromDeepLensToDynamo" {
  type        = "zip"
  source_file = "./functions/sendItemsFromDeepLensToDynamo.py"
  output_path = "./output/sendItemsFromDeepLensToDynamo.zip"
}

# CREATE LAMBDA FUNCTION TO PUT ITEMS INTO DYNAMODB
resource "aws_lambda_function" "sendItemsFromDeepLensToDynamo" {
  filename      = "./output/sendItemsFromDeepLensToDynamo.zip"
  function_name = "sendItemsFromDeepLensToDynamo"
  role          = aws_iam_role.sendItemsFromDeepLensToDynamo.arn
  handler       = "sendItemsFromDeepLensToDynamo.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.sendItemsFromDeepLensToDynamo,
  ]
}

resource "aws_lambda_permission" "AllowS3Invoke-deeplens" {
  statement_id  = "AllowS3Invoke-deeplens"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sendItemsFromDeepLensToDynamo.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.deeplens-face-rekognition-test.id}"
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "deeplens-face-rek" {
  bucket = aws_s3_bucket.deeplens-face-rekognition-test.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.sendItemsFromDeepLensToDynamo.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [
    aws_lambda_permission.AllowS3Invoke
  ]
}

##############################################################################

# CREATE ZIP FILE FOR THE FUNCTION GET ITEMS FROM DYNAMODB

data "archive_file" "getItemsFromDynamoDB" {
  type        = "zip"
  source_file = "./functions/getItemsFromDynamoDB.js"
  output_path = "./output/getItemsFromDynamoDB.zip"
}

# CREATE LAMBDA function to get_items from dynamodb
resource "aws_lambda_function" "getItemsFromDynamoDB" {
  filename      = "./output/getItemsFromDynamoDB.zip"
  function_name = "getItemsFromDynamoDB"
  role          = aws_iam_role.getItemsFromDynamo.arn
  handler       = "getItemsFromDynamoDB.handler"
  runtime       = "nodejs14.x"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.getItemsFromDynamo,
  ]
}

####################################################################################

## Add images to s3 bucket function
data "archive_file" "addImageToS3" {
  type        = "zip"
  source_file = "./functions/addImageToS3.py"
  output_path = "./output/addImageToS3.zip"
}

# CREATE LAMBDA functions
resource "aws_lambda_function" "addImageToS3" {
  filename      = "./output/addImageToS3.zip"
  function_name = "addImageToS3"
  role          = aws_iam_role.simpleLambdaRole.arn
  handler       = "addImageToS3.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.simpleLambdaRole,
  ]
}


####################################################################################

## INDEX FACES function
data "archive_file" "indexFaces" {
  type        = "zip"
  source_file = "./functions/indexFaces.py"
  output_path = "./output/indexFaces.zip"
}

# CREATE LAMBDA functions
resource "aws_lambda_function" "indexFaces" {
  filename      = "./output/indexFaces.zip"
  function_name = "indexFaces"
  role          = aws_iam_role.indexFacesRole.arn
  handler       = "indexFaces.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.indexFacesRole,
  ]
}

resource "aws_lambda_permission" "AllowS3Invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.indexFaces.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.terega-prisesdevues-test.id}"
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "s3-index-faces-trigger" {
  bucket = aws_s3_bucket.terega-prisesdevues-test.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.indexFaces.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [
    aws_lambda_permission.AllowS3Invoke
  ]
}


####################################################################################

## Create Collection function
data "archive_file" "createCollection" {
  type        = "zip"
  source_file = "./functions/createCollection.py"
  output_path = "./output/createCollection.zip"
}

# CREATE LAMBDA functions
resource "aws_lambda_function" "createCollection" {
  filename      = "./output/createCollection.zip"
  function_name = "createCollection"
  role          = aws_iam_role.simpleLambdaRole.arn
  handler       = "createCollection.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.simpleLambdaRole,
  ]
}

####################################################################################

## Create listFaces function

# CREATE Lambda

data "archive_file" "listFaces" {
  type        = "zip"
  source_file = "./functions/listFaces.py"
  output_path = "./output/listFaces.zip"
}

# CREATE LAMBDA function to get_items from dynamodb
resource "aws_lambda_function" "listFaces" {
  filename      = "./output/listFaces.zip"
  function_name = "listFaces"
  role          = aws_iam_role.listFaces_role.arn
  handler       = "listFaces.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      region     = var.region
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
  depends_on = [
    aws_iam_role.listFaces_role,
  ]
}


