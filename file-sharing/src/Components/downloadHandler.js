import axios from 'axios';
var bufferToArrayBuffer = require('buffer-to-arraybuffer');
const crypto = require('crypto');

function getCipherKey(password) {
    return crypto.createHash('sha256').update(password).digest();
}

function createHMAC(password,file){
  const hmac = crypto.createHmac('sha256', getCipherKey(password));

  hmac.update(file);
  return hmac.digest('hex');
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

export const downloadHandler=(fid,fileName,key)=>{

    axios.get(`${process.env.REACT_APP_DOWNLOAD_URL}/presignedurl?fid=${fid}`).then((res)=>{

     if(res.data.fileDownloadURL){
      console.log(res.data.fileDownloadURL)

       axios({method:"GET",url:res.data.fileDownloadURL,responseType:'arraybuffer'}).then((response) => {

        const buffer=arrayBufferToBufferCycle(response.data);

        const initVect = Buffer.alloc(16, 0);
        const CIPHER_KEY = getCipherKey(key.enckey);

       const decipher = crypto.createDecipheriv('aes-256-ctr', CIPHER_KEY,initVect);
       var decrypted = Buffer.concat([decipher.update(buffer) , decipher.final()]);

       console.log(createHMAC(decrypted,key.enckey) == key.hmac);

       // checking hmac code for data authentication

       if(createHMAC(decrypted,key.enckey) == key.hmac){

         const url = window.URL.createObjectURL(new Blob([ bufferToArrayBuffer(decrypted)]));
         const link = document.createElement('a');
         link.href = url;
         link.setAttribute('download', `${fileName}`); //or any other extension
         document.body.appendChild(link);
         link.click();
       }else {
        alert("files has been tampered");
       }

       });

     }
    })
}
