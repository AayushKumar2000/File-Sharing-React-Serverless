 export const sizeConverter=(s)=>{
var u=" KB";

     s=s/1024;
  if(s>1024)
  {
    s=s/1024;
    u=" MB";
  }
  if(s>1024)
  {
    s=s/1024;
    u=" GB"
  }

 return s.toFixed(2)+u;

}
