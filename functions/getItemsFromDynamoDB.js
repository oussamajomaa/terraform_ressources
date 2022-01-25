const AWS = require('aws-sdk');

exports.handler = async (event) => {
  const awsConfig = {
    "access_key": process.env.access_key,
    "secret_key": process.env.secret_key,
    "region": process.env.region
  }

  
  const dynamo = new AWS.DynamoDB.DocumentClient(awsConfig);
  
  const params = {
    TableName : 'rekognition-logs'
  }
  try {
  let res
    res = await dynamo.scan(params).promise()
      return { 
        statusCode: 200,
        headers: {
          "Access-Control-Allow-Origin" : "*"
        },
        body: JSON.stringify({'items':res.Items}) 
      }
      
    
  } catch (err) {
    return { error: err }
  }
}