   var AWSXRay = require('aws-xray-sdk');
var AWS = AWSXRay.captureAWS(require('aws-sdk'));
const DynamoDb=new AWS.DynamoDB({apiVersion: '2012-08-10',region:'us-east-1'});

exports.handler =  (event,context,callback) => {
  const id= event.queryStringParameters.fid;
//	 var id=1603311316996;
   
  const params={
      TableName:"file_details",
      Key:{
         fileID:{
             S:""+id
         } 
      }
  };
     var returnObject = {
            statusCode: 200,
            headers: {
                "access-control-allow-origin": "*"
            },
           
        };
  
     DynamoDb.getItem(params,(err,data)=>{
         if(err)
          {
              console.log(err);
              callback(err);
          }else
          {
              console.log(data);
              
             try{
              returnObject.body=JSON.stringify({
                  data:true,
                  fileName:data.Item.fileName.S,
                  fileSize:data.Item.fileSize.S,
                  zipfiles:data.Item.zipFileDetails.L.map((e)=>{
                      return {fileName:e.M.fileName.S,fileSize:e.M.fileSize.S};
                  })
              });
              callback(null,returnObject);
             
                 
             }catch(err){
                 try{
                     returnObject.body=JSON.stringify({
                  data:true,
                  fileName:data.Item.fileName.S,
                           fileSize:data.Item.fileSize.S,
                  zipfiles:null
              });
              callback(null,returnObject);
             
             
                 }catch(err){
                     returnObject.body=JSON.stringify({data:null});
                     callback(null,returnObject);
                 }
                 
             }
                 
             }
     });
};
