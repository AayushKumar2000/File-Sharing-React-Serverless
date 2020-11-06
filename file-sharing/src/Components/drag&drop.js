import React,{useState,useEffect} from 'react';
import dropIcon from './img/icons8-drop-down-50.png'
import FileList from './fileList';
import JSZip from 'jszip';
import axios from 'axios';
import {sizeConverter} from './sizeConverter';
const crypto = require('crypto');
const cryptoRandomString = require('crypto-random-string');


const fs = require('fs');


const  DragAndDrop=({getUploadingFile,updateFileStatus,createEncryptKey})=>{
 const [file,setFile]=useState([]);
 const [uploadLabel,setUploadLabel]=useState(null);
 const [blueDotedLine,setBlueDotedLine]=useState({outline:"2px dashed blue"});
 const [totalSize,setTotalSize]=useState(null);
 const [errMessage,setErrMessage]=useState(null);
 const [downloads,setDownloads]=useState(1);
 const [expire,setExpire]=useState('1day');
 const TotalUploadLimit=10;





 const  handleSubmit=()=>{
   var zip=new JSZip();
   var x=null,zipFileID=null;
   var zipFiles=[];

//////////////////////////////////////////////// check
   if(file.length==0 )
    return ;


    if(parseInt(totalSize.substring(0,totalSize.indexOf(" ")))>=TotalUploadLimit
    && totalSize.substring(totalSize.indexOf(" ")+1)==="MB"){
      setErrMessage(`File Size is more than ${TotalUploadLimit} MB`);
      return ;
    }else {
      setErrMessage(null);
    }
///////////////////////////////////////////

 if(file.length>1){


   file.forEach((element) => {
     zip.file(element.name,element);
     zipFiles.push({fileName:element.name,fileSize:sizeConverter(element.size)});
   });


   zip.generateAsync({type:"blob"}).then((content)=>{
    console.log(content);
     x=content;
     encryption(x);
   })
 }else {
   x=file[0];
   encryption(x);
 }



   ///////////////zip file name random

   var fileName;

   if(file.length==1){
     fileName=file[0].name;
     // fileName=fileName.substring(0,fileName.indexOf('.'))+".zip";
   }else {
     var rn=Math.random().toString(36).substring(5);
     fileName=(rn+new Date().getTime())+".zip";
   }


   /////////////////

  ////////////// calling funcation getUploadingFile to send file details to uploading.js

   getUploadingFile(fileName,totalSize,null);
  /////////////////


//////////////////
//encryption and hmac code on zipfiles ( which is x )

function createHMAC(password,file){
  const hmac = crypto.createHmac('sha256', getCipherKey(password));

  hmac.update(file);

  return hmac.digest('hex');
}



function getCipherKey(password) {
  return crypto.createHash('sha256').update(password).digest();
}


// arrayBuffer to buffer
function arrayBufferToBufferCycle(ab) {
  var buffer = new Buffer(ab.byteLength);
  var view = new Uint8Array(ab);
  for (var i = 0; i < buffer.length; ++i) {
      buffer[i] = view[i];
  }
  return buffer;
}


  function encryption(file){

    const encrptKey=cryptoRandomString({length: 12, type: 'alphanumeric'});
  //  createEncryptKey(encrptKey,createHMAC(file,encrptKey));

    const initVect = Buffer.alloc(16, 0);
    const CIPHER_KEY = getCipherKey(encrptKey);



    const cipher = crypto.createCipheriv('aes-256-ctr', CIPHER_KEY, initVect);
    var encrypted;

    console.log(x)

    file.arrayBuffer().then(arraybuffer => {
     const buffer=arrayBufferToBufferCycle(arraybuffer);

    var encrypted = Buffer.concat([cipher.update(buffer),cipher.final()]);

  createEncryptKey(encrptKey,createHMAC(buffer,encrptKey));

  //   var newfile=new File([encrypted],file.name,{type: file.type,lastModified: file.lastModified});

     ////////////////////// saving zip file details to the dynamodb
     const filesDetails = {
       fileName,
       totalDownloads : downloads,
       fileSize: totalSize,
       totalSize,
       expireValue: expire,
       zipFileDetails : zipFiles.length!=0 ? zipFiles : []
     }

     axios.post(`${process.env.REACT_APP_UPLOAD_URL}/filedetails`,{...filesDetails}).then((res)=>{
     //res.fileID

      getUploadingFile(fileName,totalSize,res.data.fileID);

      axios.get(`${process.env.REACT_APP_UPLOAD_URL}/presignedurl?fileID=${res.data.fileID}`).then((res)=>{

      if(res.data.fileUploadURL){

        axios({method:"PUT",url:res.data.fileUploadURL,data:encrypted,onUploadProgress: function(progressEvent) {
         var percentCompleted = Math.round( progressEvent.loaded / progressEvent.total  * 100);

            updateFileStatus(percentCompleted);
           }})
       }

      })

     })

    });


   }


//calling encrpytion  function and uploading encrypted data

// encryption('123456789',x);


 }



 const removeFiles=(id)=>{

   file.forEach((element,index)=>{
      if(id==element.lastModified)
        file.splice(index,1);
   })
   setFile([...file]);

   if(file.length==0){
   setTotalSize(null)
   setUploadLabel(null);
   setBlueDotedLine({outline:"2px dashed blue"})
  }
 }

 const setSize=(s)=>{
   console.log(s);
   setTotalSize(s);
 }




  return(
   <div>
    <div className="box" style={blueDotedLine} >
     <form    encType="multipart/form-data">

        <input className="box__file" type="file"  id="file" onChange={(event)=>{
          setUploadLabel(true);
          setBlueDotedLine({outline:"none"});
          setFile([...file,...event.target.files])}} multiple />

       { uploadLabel?<FileList files={file} setSize={setSize} removeFiles={removeFiles}/>:<div className="box__label">
           <img src={dropIcon} className="box_label-icon"/>
           <label htmlFor="file"  className="box__label-text">DragnDrop or Choose a file</label>
         </div>
       }
       <div  className="file__total-size">{totalSize?`Total Size: ${totalSize}/${TotalUploadLimit} MB`:null}</div>
      </form>
   </div>
    <div className="box__downloads_option">
     <div className="box__downloads">
       <div className="box__downloads-text">Downloads</div>
       <input className="box__downloads-input"
        value={downloads}
        onChange={(event)=>setDownloads(event.target.value)}/>
     </div>
     <div className="box__expire">
       <div className="box__expire-text">Expire After</div>
         <div>
          <select className="box__expire-select" value={expire}
             onChange={(event)=>setExpire(event.target.value)} >
             <option value="1day">1 Day</option>
             <option value="2day">2 Days</option>
             <option value="3day">3 Days</option>
             <option value="4day">4 Days</option>
             <option value="7day">7 Days</option>
          </select>
         </div>
     </div>
    </div>
 <button onClick={()=>handleSubmit()} className="box__button" type="submit"><span>Upload</span></button>
 <div className="box__errMessage">{errMessage}</div>
</div>
  );
}

export default DragAndDrop;
