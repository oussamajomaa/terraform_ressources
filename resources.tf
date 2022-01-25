
# CREATE S3 BUCKET terega-prisesdevues-test
resource "aws_s3_bucket" "terega-prisesdevues-test" {
  bucket = "terega-prisesdevues-test"
  acl    = "private"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

#####################################################################################

# CREATE S3 BUCKET 
resource "aws_s3_bucket" "deeplens-face-rekognition-test" {
  bucket = "deeplens-face-rekognition-test"
  acl    = "private"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

#####################################################################################


# CREATE DYNAMODB TABLE
resource "aws_dynamodb_table" "prestataires-detection-db" {
  name           = "rekognition-logs"
  hash_key       = "PartnerID"
  range_key      = "Date"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "PartnerID"
    type = "S"
  }

  attribute {
    name = "Date"
    type = "N"
  }
}


