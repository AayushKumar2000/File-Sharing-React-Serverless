import React from 'react';
import fileIcon from './img/icons8-file-48.png'
import {sizeConverter} from './sizeConverter';

const FileList=({files,removeFiles,setSize})=>{
  console.log(files);

var x=0;

  const totalSizeCal=()=>{
    var x=0;
    files.forEach((element)=>{
      x=x+element.size;
    })
    console.log(x);
    setSize(sizeConverter(x));
  }
  return(
    <div className="fileList">
       <ul className="fileList-list">
         {
           files.map((element)=>{

              x=x+element.size;
            setSize(sizeConverter(x));
             return(
               <li className="fileList-element" key={element.lastModified}>
                <img className="fileList-element-icon" src={fileIcon}/>
                <div className="fileList-element-name">{element.name}</div>
                <div className="fileList-element-size">{sizeConverter(element.size)}</div>
                <div onClick={()=>removeFiles(element.lastModified)} className="fileList-element-cross">&#10005;</div>
               </li>
             );
           })
         }
       </ul>
    </div>
  );
}

export default FileList;
