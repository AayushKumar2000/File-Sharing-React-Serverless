var AWSXRay = require('aws-xray-sdk');
var AWS = require('aws-sdk');
const s3 = new AWS.S3({ signatureVersion: "v4" });
const bucketName = "filesharing2000";
const expirationInSeconds = 120;
const DynamoDb=new AWS.DynamoDB({apiVersion: '2012-08-10',region:'us-east-1'});

exports.handler =  (event, context,callback) => {
    
   //const key = event.queryStringParameters.fileName;

          const fId=new Date().getTime();
          const fileName=event.queryStringParameters.fileName;
          const expireValue=event.queryStringParameters.expireValue;
          const totalDownloads=event.queryStringParameters.totalDownloads;
          const fileSize=event.queryStringParameters.fileSize;
    
 //   Params object for creating the 
    const params = {
        Bucket: bucketName,
        Key: ""+fId,
        ContentType: "multipart/form-data",
        Expires: expirationInSeconds
    };
    
      
  
        
        
       (async ()=>{
            // Creating the presigned Url
             const preSignedURL=await s3.getSignedUrl("putObject", params);
            
          
               const params2={
                   Item: {
                   fileID: {
                      S: ""+fId
                     },
                 fileName: {
                     S: ""+fileName
                },
                expireValue: {
                     S: ""+expireValue
                },
                totalDownloads: {
                     N: ""+totalDownloads
                },
                currentDownloads: {
                    N: ""+0
                },
                fileSize: {
                    S: ""+fileSize
                }
                
               },
             TableName:"file_details"
           };
           
           const returnObject = {
            statusCode: 200,
            headers: {
                "access-control-allow-origin": "*"
            },
            body: JSON.stringify({
                 fileUploadURL: preSignedURL,
                 fileID:fId
               
            })
        };
        
             DynamoDb.putItem(params2,function (err,data){
          if(err){
          console.log(err);
          callback(err);
          
          }else{
          console.log("sucessfull");
          callback(null,returnObject);
         }});
        })();
          
        
        
        
       
        
       
   
};
