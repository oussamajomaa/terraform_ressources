# -------------------------------------------------------------------------------------------------------------
# CREATE REST API GETWAY
# -------------------------------------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name = "terega-rest-apis"
  description = "creating rest apis endpoints for lambda functions"
  binary_media_types = [
    "image/jpeg",
  ]
}


# -------------------------------------------------------------------------------------------------------------
# API TERRAFORM FOR createCollection FUNCTION
# -------------------------------------------------------------------------------------------------------------

# CREATE API RESOURCE FOR Create Collection FUNCTION
resource "aws_api_gateway_resource" "create-collection-resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "create-collection"
}

# CREATE API RESOURCE METHOD
resource "aws_api_gateway_method" "create-collection-method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.create-collection-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# ATTACH LAMBDA functions TO METHOD
resource "aws_api_gateway_integration" "create-collection-integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.create-collection-resource.id
  http_method = aws_api_gateway_method.create-collection-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createCollection.invoke_arn
}

# ADD PERMISSION TO API SO THAT IT CAN INVOKE THE FUNCTION
resource "aws_lambda_permission" "create-collection-permission" {
  statement_id = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.createCollection.function_name}"
  principal = "apigateway.amazonaws.com"
}



# -------------------------------------------------------------------------------------------------------------
# API TERRAFORM FOR getItemsFromDynamoDB FUNCTION
# -------------------------------------------------------------------------------------------------------------

# GET ITEMS FROM DYNAMO DB
resource "aws_api_gateway_resource" "getItemsFromDynamoDB-resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "prestataires"
}

# CREATE API RESOURCE METHOD
resource "aws_api_gateway_method" "getItemsFromDynamoDB-method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.getItemsFromDynamoDB-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# ATTACH LAMBDA functions TO METHOD
resource "aws_api_gateway_integration" "getItemsFromDynamoDB-integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.getItemsFromDynamoDB-resource.id
  http_method = aws_api_gateway_method.getItemsFromDynamoDB-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getItemsFromDynamoDB.invoke_arn
}

# ADD PERMISSION TO API SO THAT IT CAN INVOKE THE FUNCTION
resource "aws_lambda_permission" "getItemsFromDynamoDB-permission" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getItemsFromDynamoDB.function_name}"
  principal     = "apigateway.amazonaws.com"
}



# -------------------------------------------------------------------------------------------------------------
# ADD IMAGE TO S3
# -------------------------------------------------------------------------------------------------------------


# CREATE API RESOURCE
resource "aws_api_gateway_resource" "addImageToS3_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload"
}

# CREATE API RESOURCE METHOD
resource "aws_api_gateway_method" "addImageToS3_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.addImageToS3_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# ATTACH LAMBDA functions TO METHOD (INTEGRATION)
resource "aws_api_gateway_integration" "addImageToS3_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.addImageToS3_resource.id
  http_method = aws_api_gateway_method.addImageToS3_method.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.addImageToS3.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates       = {                 
            "image/jpeg"  = "${file("mapping_template.template")}"
  }
}


# ADD PERMISSION TO API SO THAT IT CAN INVOKE THE FUNCTION
resource "aws_lambda_permission" "api-permission" {
statement_id  = "AllowExecutionFromApiGateway"
action        = "lambda:InvokeFunction"
function_name = "${aws_lambda_function.addImageToS3.function_name}"
principal     = "apigateway.amazonaws.com"
}

# ENABLE CORS FOR POST METHOD
module "confirm_cors" {
  source    = "mewa/apigateway-cors/aws"
  version   = "2.0.1"

  api       = aws_api_gateway_rest_api.api.id
  resource  = aws_api_gateway_resource.addImageToS3_resource.id
  methods   = ["OPTIONS","HEAD","GET","POST","PUT","PATCH","DELETE"]
  origin    = "*"
  headers   = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key"
  ]
}


resource "aws_api_gateway_gateway_response" "response_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_4XX"

  response_templates    = {
    "application/json"  = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Methods": "'OPTIONS,POST'"
    "gatewayresponse.header.Access-Control-Allow-Origin": "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"  
  }
}

resource "aws_api_gateway_gateway_response" "response_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_5XX"

  response_templates    = {
    "application/json"  = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Methods": "'OPTIONS,POST'"
    "gatewayresponse.header.Access-Control-Allow-Origin": "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.addImageToS3_resource.id
  http_method = aws_api_gateway_method.addImageToS3_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.addImageToS3_resource.id
  http_method = aws_api_gateway_method.addImageToS3_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on  = [
    aws_api_gateway_integration.addImageToS3_integration
  ]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


# -------------------------------------------------------------------------------------------------------------
# GET LIST OF FACES IDS
# -------------------------------------------------------------------------------------------------------------

# CREATE API RESOURCE
resource "aws_api_gateway_resource" "collection_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "collection"
}

# CREATE API RESOURCE METHOD
resource "aws_api_gateway_method" "collection_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.collection_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# ATTACH LAMBDA functions TO METHOD
resource "aws_api_gateway_integration" "collection_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.collection_resource.id
  http_method = aws_api_gateway_method.collection_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.listFaces.invoke_arn
}

# ADD PERMISSION TO API SO THAT IT CAN INVOKE THE FUNCTION
resource "aws_lambda_permission" "listFaces_permission" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.listFaces.function_name
  principal     = "apigateway.amazonaws.com"
}


# -------------------------------------------------------------------------------------------------------------
# DELETE FACE ID
# -------------------------------------------------------------------------------------------------------------

# CREATE API RESOURCE DELETE
resource "aws_api_gateway_resource" "collection_resource_delete" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "delete-face"
}

# CREATE API RESOURCE METHOD
resource "aws_api_gateway_method" "collection_method_delete" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.collection_resource_delete.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# ATTACH LAMBDA functions TO METHOD
resource "aws_api_gateway_integration" "collection_integration_delete" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.collection_resource_delete.id
  http_method = aws_api_gateway_method.collection_method_delete.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.listFaces.invoke_arn
}

# ADD PERMISSION TO API SO THAT IT CAN INVOKE THE FUNCTION
resource "aws_lambda_permission" "listFaces_permission_delete" {
  statement_id  = "AllowExecutionFromApiGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.listFaces.function_name
  principal     = "apigateway.amazonaws.com"
}


# # ENABLE CORS FOR DELETE METHOD
module "confirm_cors_delete" {
  source    = "mewa/apigateway-cors/aws"
  version   = "2.0.1"

  api       = aws_api_gateway_rest_api.api.id
  resource  = aws_api_gateway_resource.collection_resource_delete.id
  methods   = ["OPTIONS","HEAD","GET","POST","PUT","PATCH","DELETE"]
  origin    = "*"
  headers   = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key"
  ]
}


resource "aws_api_gateway_gateway_response" "response_4xx_delete" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_4XX"

  response_templates    = {
    "application/json"  = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Methods": "'OPTIONS,DELETE'"
    "gatewayresponse.header.Access-Control-Allow-Origin": "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"  
  }
}

resource "aws_api_gateway_gateway_response" "response_5xx_delete" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_5XX"

  response_templates    = {
    "application/json"  = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Methods": "'OPTIONS,POST'"
    "gatewayresponse.header.Access-Control-Allow-Origin": "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}


# ----------------------------------------------------------------------
# DEPLOY API
# ----------------------------------------------------------------------
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.create-collection-integration,
    aws_api_gateway_integration.getItemsFromDynamoDB-integration,
    aws_api_gateway_integration.addImageToS3_integration,
    aws_api_gateway_integration.collection_integration,
    aws_api_gateway_integration.collection_integration_delete,
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "fabriqueNumerique"
}


output "url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
