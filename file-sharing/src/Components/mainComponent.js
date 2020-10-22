import React,{useState} from 'react';
import  DragAndDrop from './drag&drop';
import Uplpoading from './uploading';


const MainComponent=()=>{
const [fileDetails,setFileDetails]=useState(null);
const [fileStatus,updateFileStatus]=useState(0);
const [encrptKey,setEncryptKey]=useState(null);

 const getUploadingFile=(fn,s,id)=>{
   console.log(fn,s);
   setFileDetails({fileName:fn,fileSize:s,fileID:id});
   updateFileStatus(0);
 }

// setting encryption key
const createEncryptKey=(key,hmac)=>{
  console.log("key:"+key);
  setEncryptKey({
    enckey: key,
    hmac
  });

}


///// to prevent default behaviour of the browser outside the input tag
 window.addEventListener("dragover",function(e){
   if (e.target.tagName != "INPUT") {
     e.preventDefault();
   }
 },false);

 window.addEventListener("drop",function(e){
   if (e.target.tagName != "INPUT") {
     e.preventDefault();
   }
 },false);
/////////////////////////////////////////////

  return (
    <div   className="container">
     <div  className="sub-container">
      <div>
       <div className="heading">
         <span>FileSend</span>
       </div>
       <div className="upload__container">
         <DragAndDrop getUploadingFile={getUploadingFile} updateFileStatus={updateFileStatus} createEncryptKey={createEncryptKey}/>
       </div>
       </div>
       <div className="uploading__container">
         <Uplpoading fileDetails={fileDetails} uploadStatus={fileStatus} encrptKey={encrptKey}/>
       </div>
     </div>
    </div>
  );
}

export default MainComponent;
