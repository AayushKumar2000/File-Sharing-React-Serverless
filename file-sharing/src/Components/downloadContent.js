import React,{useEffect,useState} from 'react';

import fileIcon from './img/icons8-file-48.png';
import downloadIcon from './img/icons8-download-24.png';
import downArrowIcon from './img/icons8-expand-arrow-50.png';
import axios from 'axios';
import {downloadHandler} from './downloadHandler';

const DownloadContent=(props)=>{
  useEffect(()=>{
    var id=(props.match.params.fileid).split(':')[0];

    axios.get(`${process.env.REACT_APP_DOWNLOAD_URL}/getfiledetails?id=${id}`).then((res)=>{

       if(Object.keys(res.data).length !== 0){
         setFileData(res.data);

       }else
         setFileData(0);

    })
  },[]);

  const [fileData,setFileData]=useState(null);
  const [fileList,setFileList]=useState(null);







const showFileList=()=>{
console.log(fileList ,fileData.zipFileDetails);
 if(!fileList && fileData.zipFileDetails.length>0){

  const x=  fileData.zipFileDetails.map((element)=>{
       return(

         <li className="downloadFile__container__fileList-file">
          <img className="downloadFile__container__fileList-file-icon" src={fileIcon} />
          <div className="downloadFile__container__fileList-file-info">
           <div className="downloadFile__container__fileList-file-name">{element.fileName}</div>
           <div className="downloadFile__container__fileList-file-size">{element.fileSize}</div>
         </div>
         </li>

       )
    });
    console.log(x);
  setFileList(x);
}else
  setFileList(null);

}




  if(fileData==null)
  return(
  <div className="container">
   <div  className="sub-container">
    <div>
       <div className="heading">
         <span>FileSend</span>
       </div >
       <div className="container__center">

         <div className="heading__sub">
           <span >Download Files</span>
         </div>
         </div>
         </div>
       </div>
     </div>
   );



  return (
<div>
  <div className="container">
   <div  className="sub-container">
    <div>
       <div className="heading">
         <span>FileSend</span>
       </div >
       <div className="container__center">

         <div className="heading__sub">
           <span >Download Files</span>
         </div>
         {

         fileData==0?<div className="downloadFile__NoFile">No files found or may be link is expired !</div>:<div>
         <div className="downloadFile__container">
           <div style={{"display":"flex"}}>
            <img src={fileIcon} className="downloadFile__container-icon"/>
            <div className="downloadFile__container-fileInfo">
              <span className="downloadFile__container-fileInfo-name">{fileData.fileName}</span>
              <div className="downloadFile__container-fileInfo-size">
              <span>{fileData.fileSize}</span>
              <img onClick={()=>showFileList()} style={fileList?{"transform":"rotate(180deg)"}:{"transform":"rotate(0deg)"}} className="downloadFile__container-dropdown" src={downArrowIcon} />
              </div>
            </div>
           </div>
            <div>
              <ul  style={fileList?null:{display:"none"}} className="downloadFile__container__fileList">
               {fileList}
              </ul>
            </div>
            <div>

            </div>
         </div>
         <div onClick={()=>downloadHandler((props.match.params.fileid).split(':')[0],fileData.fileName,
                {
                  enckey: (props.match.params.fileid).split(':')[1],
                  hmac: (props.match.params.fileid).split(':')[2]
                }
              )} className="downloadFile__Button">
           <span className="downloadFile__Button-text">Download</span>
           <img  className="downloadFile__Button-icon" src={downloadIcon}/>
        </div>
      </div>

      }
      </div>
      </div>
    </div>
  </div>
</div>
  );
}

export default DownloadContent;
