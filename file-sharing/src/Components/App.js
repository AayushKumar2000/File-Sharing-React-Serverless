import React from 'react';
import MainComponent from './mainComponent';
import DownloadComponent from './downloadContent';
import {Route,Router} from 'react-router-dom';
import history from '../history';
import './main.scss';


function App() {

  return (
  <div>
    <Router history={history}>
     <Route path="/" exact component={MainComponent}/>
     <Route path="/download/:fileid" exact component={DownloadComponent}/>
    </Router>
  </div>
  );
}

export default App;
