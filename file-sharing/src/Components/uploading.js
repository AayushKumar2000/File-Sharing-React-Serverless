import React,{useState,useEffect} from 'react';
import zipFileIcon from './img/icons8-zip-48.png';
import copyIcon from './img/icons8-copy-link-26.png';
import downloadIcon from './img/icons8-download-24.png';
import axios from 'axios';
import {downloadHandler} from './downloadHandler';




const Uploading=({fileDetails,uploadStatus,encrptKey})=>{
  console.log(fileDetails,uploadStatus);

 //const [link,setLink]=useState(null);



const domain=window.location.port==3000?`${window.location.hostname}:${window.location.port}`:`${window.location.hostname}`;

if(!fileDetails){
  return null;
}
  const content= fileDetails.fileName.search(".zip")==-1?fileDetails.fileName:"Archive file";

//  if(uploadStatus==0 && link)
//  setLink(null);

//if(uploadStatus==100 && !link){
//  axios.get(`${process.env.REACT_APP_DOWNLOAD_URL}/presignedurl?fileName=${fileDetails.fileName}&fid=${fileDetails.fileID}&fs=${fileDetails.fileSize}`).then((res)=>{
//  setLink(res.data.fileDownloadURL);


// });
//}



  const copyLink=()=>{
    var txt = document.getElementsByClassName('uploading__block__link-actualLink');
    console.log(txt[0]);
    txt[0].select();
    console.log(txt[0].select());
     document.execCommand("copy");
  }



  return (
    <div>
      <div className="uploading__block">
       <div className="uploading__block-heading">
         {uploadStatus==100?`Uploaded ${content}`:`Uploading ${content}....`}
       </div>
       <div className="uploading__block__item">
        <div className="uploading__block__item-icon">
          <img src={zipFileIcon}/>
        </div>
        <div  className="uploading__block__item-info">
          <div className="uploading__block__item-name">
            {fileDetails.fileName}
          </div>
          <div className="uploading__block__item-size">

           {fileDetails.fileSize}
          </div>
       </div>
      </div>
      <div className="uploading__block__progress">
         <span className="uploading__block__progress-digit">{uploadStatus}%</span>
         <progress  className="uploading__block__progress-Bar" max="100" value={uploadStatus}></progress>
      </div>
    {

      uploadStatus==100?
       <div className="uploading__block__link">
         <input className="uploading__block__link-actualLink"
           value={`${domain}/download/${fileDetails.fileID}:${encrptKey.enckey}:${encrptKey.hmac}`}
         />
         <div className="uploading__block__link-button">
        <div  onClick={()=>copyLink()} className="uploading__block__link-copyLink">
          Copy Link <img className="uploading__block__link-copyLink-icon"src={copyIcon}/>
        </div>
        <div  onClick={()=>downloadHandler(fileDetails.fileID,fileDetails.fileName,encrptKey)} className="uploading__block__link-download">
          <span className="uploading__block__link-download-text">Download </span>
          <img className="uploading__block__link-download-icon"src={downloadIcon}/>
        </div>
        </div>
       </div>:<div></div>

     }
     </div>
    </div>
  );
}

export default Uploading;
