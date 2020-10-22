import React from 'react';
import MainComponent from './mainComponent';
import DownloadComponent from './downloadContent';
import {Route,BrowserRouter} from 'react-router-dom';
import './main.scss';


function App() {

  return (
  <div>
    <BrowserRouter>
     <Route path="/" exact component={MainComponent}/>
     <Route path="/download/:fileid" exact component={DownloadComponent}/>
    </BrowserRouter>
  </div>
  );
}

export default App;
