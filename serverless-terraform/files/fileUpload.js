var AWSXRay = require('aws-xray-sdk');
var AWS = require('aws-sdk');
const s3 = new AWS.S3({ signatureVersion: "v4" });
const bucketName = "filesharing2000";
const expirationInSeconds = 120;
const DynamoDb=new AWS.DynamoDB({apiVersion: '2012-08-10',region:'us-east-1'});

exports.handler =   (event, context,callback) => {
    
         
          const fId=event.queryStringParameters.fileID;
    
 //   Params object for creating the 
    const params = {
        Bucket: bucketName,
        Key: ""+fId,
        ContentType: "multipart/form-data",
        Expires: expirationInSeconds
    };
    
     s3.getSignedUrl("putObject", params,(error, url)=>{
         
         var res={};
         
         
         if(!error)
          res = JSON.stringify({
                 fileUploadURL: url
               
            });
    
         
          const returnObject = {
            statusCode: 200,
            headers: {
                "access-control-allow-origin": "*"
            },
            body:res
            }
            
            callback(null, returnObject);
        }
     );
      
  
        
       
       
   
};
