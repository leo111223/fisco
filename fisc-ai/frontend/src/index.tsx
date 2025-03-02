import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import { QuickstartProvider } from "./Context";
import reportWebVitals from "./reportWebVitals";
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';

Amplify.configure(awsconfig);


ReactDOM.render(
  <React.StrictMode>
    <QuickstartProvider>
      <App />
    </QuickstartProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
