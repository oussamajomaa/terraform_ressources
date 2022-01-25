
# ##############################################################################

# CREATE IAM LAMBDA EXECUTION ROLE TO GET RECORDS FROM DEEPLENS AND PUT ITEMS INTO DYNAMODB
resource "aws_iam_role" "sendItemsFromDeepLensToDynamo" {
  name               = "sendItemsFromDeepLensToDynamo"
  assume_role_policy = file("./policies/AssumRolePolicyLambda.json")
  
}


# POLICY XRAY WRITE ONLY ACCESS
resource "aws_iam_role_policy" "AWSXrayWriteOnlyAccess" {
  name   = "AWSXrayWriteOnlyAccess"
  role   = aws_iam_role.sendItemsFromDeepLensToDynamo.id
  policy = file("./policies/AWSXrayWriteOnlyAccess.json")
  depends_on = [
    aws_iam_role.sendItemsFromDeepLensToDynamo,
  ]
}

# POLICY LAMBDA BASIC EXECUTION ROLE 
resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRole" {
  name   = "AWSLambdaBasicExecutionRole"
  role   = aws_iam_role.sendItemsFromDeepLensToDynamo.id
  policy = file("./policies/AWSLambdaBasicExecutionRole.json")
  depends_on = [
    aws_iam_role.sendItemsFromDeepLensToDynamo,
  ]
}


# POLICY TO DECRYPTE ENVIRONMENT VARIABLES
resource "aws_iam_role_policy" "kmsDecrypte_deepLensIndexface" {
  name   = "kmsDecrypte"
  role   = aws_iam_role.sendItemsFromDeepLensToDynamo.id
  policy = file("./policies/kmsDecrypte.json")
  depends_on = [
    aws_iam_role.sendItemsFromDeepLensToDynamo,
  ]
}


########################################################################################
# CREATE ASSUME ROLE TO GET DATA FROM DYNAMODB
resource "aws_iam_role" "getItemsFromDynamo" {
  name               = "getItemsFromDynamo"
  assume_role_policy = file("./policies/AssumRolePolicyLambda.json")
}


# POLICY XRAY WRITE ONLY ACCESS
resource "aws_iam_role_policy" "AWSXrayWriteOnlyAccessGet" {
  name   = "AWSXrayWriteOnlyAccessGet"
  role   = aws_iam_role.getItemsFromDynamo.id
  policy = file("./policies/AWSXrayWriteOnlyAccess.json")
  depends_on = [
    aws_iam_role.getItemsFromDynamo,
  ]
}

# POLICY LAMBDA BASIC EXECUTION ROLE 
resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRoleGet" {
  name   = "AWSLambdaBasicExecutionRoleGet"
  role   = aws_iam_role.getItemsFromDynamo.id
  policy = file("./policies/AWSLambdaBasicExecutionRole.json")
  depends_on = [
    aws_iam_role.getItemsFromDynamo,
  ]
}

# POLICY TO DECRYPTE ENVIRONMENT VARIABLES
resource "aws_iam_role_policy" "kmsDecrypte_getItem" {
  name   = "kmsDecrypte"
  role   = aws_iam_role.getItemsFromDynamo.id
  policy = file("./policies/kmsDecrypte.json")
  depends_on = [
    aws_iam_role.getItemsFromDynamo,
  ]
}

# POLICY LAMBDA SCAN AND PUT IN DYNAMO DB 
resource "aws_iam_role_policy" "allowLambdaDynamo" {
  name   = "allowLambdaDynamo"
  role   = aws_iam_role.getItemsFromDynamo.id
  policy = file("./policies/allowLambdaDynamo.json")
  depends_on = [
    aws_iam_role.getItemsFromDynamo,
  ]
}

########################################################################################

# CREATE ASSUME ROLE WILL BE ATTACHED TO:
# ADD IMAGE INTO S3 

resource "aws_iam_role" "simpleLambdaRole" {
  name               = "simpleLambdaRole"
  assume_role_policy = file("./policies/AssumRolePolicyLambda.json")
}


# POLICY XRAY WRITE ONLY ACCESS
resource "aws_iam_role_policy" "AWSXrayWriteOnlyAccesss3" {
  name   = "AWSXrayWriteOnlyAccesss3"
  role   = aws_iam_role.simpleLambdaRole.id
  policy = file("./policies/AWSXrayWriteOnlyAccess.json")
  depends_on = [
    aws_iam_role.simpleLambdaRole,
  ]
}

# POLICY LAMBDA BASIC EXECUTION ROLE 
resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRoles3" {
  name   = "AWSLambdaBasicExecutionRoles3"
  role   = aws_iam_role.simpleLambdaRole.id
  policy = file("./policies/AWSLambdaBasicExecutionRole.json")
  depends_on = [
    aws_iam_role.simpleLambdaRole,
  ]
}

# POLICY TO DECRYPTE ENVIRONMENT VARIABLES WILL BE ATTACHED TO ALL LAMBDA FUNCTIONS
resource "aws_iam_role_policy" "kmsSimpleLambda" {
  name   = "kmsDecrypte"
  role   = aws_iam_role.simpleLambdaRole.id
  policy = file("./policies/kmsDecrypte.json")
  depends_on = [
    aws_iam_role.simpleLambdaRole,
  ]
}

########################################################################################

# CREATE EXECUTION LAMBDA ROLE TO INDEX FACES
resource "aws_iam_role" "indexFacesRole" {
  name               = "indexFacesRole"
  assume_role_policy = file("./policies/AssumRolePolicyLambda.json")
}


# POLICY TO DECRYPTE ENVIRONMENT VARIABLES WILL BE ATTACHED TO ALL LAMBDA FUNCTIONS
resource "aws_iam_role_policy" "kmsSimpleLambda_execution_policy_lambda" {
  name   = "kmsDecrypte"
  role   = aws_iam_role.indexFacesRole.id
  policy = file("./policies/kmsDecrypte.json")
  depends_on = [
    aws_iam_role.indexFacesRole,
  ]
}

# POLICY XRAY WRITE ONLY ACCESS WILL BE ATTACHED TO LAMBDA EXECUTION ROLE
resource "aws_iam_role_policy" "AWSXrayWriteOnlyAccess_puts3" {
  name   = "AWSXrayWriteOnlyAccess"
  role   = aws_iam_role.indexFacesRole.id
  policy = file("./policies/AWSXrayWriteOnlyAccess.json")
  depends_on = [
    aws_iam_role.indexFacesRole,
  ]
}

# POLICY LAMBDA BASIC EXECUTION ROLE WILL BE ATTACHED TO LAMBDA EXECUTION ROLE
resource "aws_iam_role_policy" "AWSLambdaBasicExecutionRole_puts3" {
  name   = "AWSLambdaBasicExecutionRole"
  role   = aws_iam_role.indexFacesRole.id
  policy = file("./policies/AWSLambdaBasicExecutionRole.json")
  depends_on = [
    aws_iam_role.indexFacesRole,
  ]
}


########################################################################################

# CRATE ROLE FOR listFaces FUNCTION

resource "aws_iam_role" "listFaces_role" {
  name               = "listFaces_role"
  assume_role_policy = file("./policies/AssumRolePolicyLambda.json")
}


# POLICY TO DECRYPTE ENVIRONMENT VARIABLES WILL BE ATTACHED TO ALL LAMBDA FUNCTIONS
resource "aws_iam_role_policy" "listFaces_kmsDecrypte" {
  name   = "kmsDecrypte"
  role   = aws_iam_role.listFaces_role.id
  policy = file("./policies/kmsDecrypte.json")
  depends_on = [
    aws_iam_role.listFaces_role,
  ]
}

# POLICY XRAY WRITE ONLY ACCESS WILL BE ATTACHED TO LAMBDA EXECUTION ROLE
resource "aws_iam_role_policy" "listFaces_AWSXrayWriteOnlyAccess" {
  name   = "AWSXrayWriteOnlyAccess"
  role   = aws_iam_role.listFaces_role.id
  policy = file("./policies/AWSXrayWriteOnlyAccess.json")
  depends_on = [
    aws_iam_role.listFaces_role,
  ]
}

# POLICY LAMBDA BASIC EXECUTION ROLE WILL BE ATTACHED TO LAMBDA EXECUTION ROLE
resource "aws_iam_role_policy" "listFaces_AWSLambdaBasicExecutionRole" {
  name   = "AWSLambdaBasicExecutionRole"
  role   = aws_iam_role.listFaces_role.id
  policy = file("./policies/AWSLambdaBasicExecutionRole.json")
  depends_on = [
    aws_iam_role.listFaces_role,
  ]
}
