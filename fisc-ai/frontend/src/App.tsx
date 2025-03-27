import React, { useEffect, useContext, useCallback, useState } from "react";
import { signOut as amplifySignOut } from '@aws-amplify/auth';

import Header from "./Components/Headers";
import Products from "./Components/ProductTypes/Products";
import Items from "./Components/ProductTypes/Items";
import Context from "./Context";
import Sidebar from './Components/Sidebar';
import ChatWidget from './Components/ChatWidget';
import Institutions from './Components/Institutions';

import { CraCheckReportProduct } from "plaid";
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';
import type { WithAuthenticatorProps } from '@aws-amplify/ui-react';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import './App.css';
import { usePlaidLink } from "react-plaid-link";
Amplify.configure(awsconfig);

// const API_BASE_URL = "https://7o81y9tcsa.execute-api.us-east-1.amazonaws.com/dev";
const API_BASE_URL = "https://u7t4ewvr2a.execute-api.us-east-1.amazonaws.com/transaction";
//const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;     //leo

// const App = ({ signOut, user }: WithAuthenticatorProps) => {
  
//   const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
//     useContext(Context);
//   const [institutions, setInstitutions] = useState([]);

//   // const getInfo = useCallback(async () => {
//   //   const response = await fetch(`${API_BASE_URL}/info`, { method: "POST" });
//   //   if (!response.ok) {
//   //     dispatch({ type: "SET_STATE", state: { backend: false } });
//   //     return { paymentInitiation: false };
//   //   }
//   //   const data = await response.json();
//   //   const paymentInitiation: boolean =
//   //     data.products.includes("payment_initiation");
//   //   const craEnumValues = Object.values(CraCheckReportProduct);
//   //   const isUserTokenFlow: boolean = data.products.some(
//   //     (product: CraCheckReportProduct) => craEnumValues.includes(product)
//   //   );
//   //   const isCraProductsExclusively: boolean = data.products.every(
//   //     (product: CraCheckReportProduct) => craEnumValues.includes(product)
//   //   );
//   //   dispatch({
//   //     type: "SET_STATE",
//   //     state: {
//   //       products: data.products,
//   //       isPaymentInitiation: paymentInitiation,
//   //       isCraProductsExclusively: isCraProductsExclusively,
//   //       isUserTokenFlow: isUserTokenFlow,
//   //     },
//   //   });
//   //   return { paymentInitiation, isUserTokenFlow };
//   // }, [dispatch]);

  
//   // const generateUserToken = useCallback(async () => { // these are to the local server on Port 8000 not the Plaid API. Only the LinkWidget is connected to the Plaid API
//   //   const response = await fetch(`${API_BASE_URL}/create_user_token`, { method: "POST" });  // api/create_user_token
//   //   if (!response.ok) {
//   //     dispatch({ type: "SET_STATE", state: { userToken: null } });
//   //     // log error
//   //     console.log("Error generating user token");
//   //     return;
//   //   }
//   //   const data = await response.json();
//   //   if (data) {
//   //     if (data.error != null) {
//   //       dispatch({
//   //         type: "SET_STATE",
//   //         state: {
//   //           linkToken: null,
//   //           linkTokenError: data.error,
//   //         },
//   //       });
//   //       return;
//   //     }
//   //     dispatch({ type: "SET_STATE", state: { userToken: data.user_token } });
//   //     return data.user_token;
//   //   }
//   // }, [dispatch]);

//   const generateToken = useCallback(
//     async (isPaymentInitiation: boolean) => {
//       // Link tokens for 'payment_initiation' use a different creation flow in your backend.
//       const path = isPaymentInitiation
//       ? `${API_BASE_URL}/create_link_token`
//       : `${API_BASE_URL}/create_user_token`;
//       const response = await fetch(path, {
//         method: "POST",
//       });
//       if (!response.ok) {
//         dispatch({ type: "SET_STATE", state: { linkToken: null } });
//         return;
//       }
//       const data = await response.json();
//       if (data) {
//         if (data.error != null) {
//           dispatch({
//             type: "SET_STATE",
//             state: {
//               linkToken: null,
//               linkTokenError: data.error,
//             },
//           });
//           return;
//         }
//         dispatch({ type: "SET_STATE", state: { linkToken: data.link_token } });
//       }
//       // Save the link_token to be used later in the Oauth flow.
//       localStorage.setItem("link_token", data.link_token);
//     },
//     [dispatch]
//   );

//   const fetchInstitutions = useCallback(async () => {
//     try {
//       const response = await fetch('/api/institutions', {
//         method: 'GET',
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       });
      
//       if (!response.ok) {
//         throw new Error('Failed to fetch institutions');
//       }
      
//       const data = await response.json();
//       setInstitutions(data.institutions);
//     } catch (error) {
//       console.error('Error fetching institutions:', error);
//     }
//   }, []);

//   // useEffect(() => {
//   //   const init = async () => {
//   //     const { paymentInitiation, isUserTokenFlow } = await getInfo(); // used to determine which path to take when generating token
//   //     // do not generate a new token for OAuth redirect; instead
//   //     // setLinkToken from localStorage
//   //     if (window.location.href.includes("?oauth_state_id=")) {
//   //       dispatch({
//   //         type: "SET_STATE",
//   //         state: {
//   //           linkToken: localStorage.getItem("link_token"),
//   //         },
//   //       });
//   //       return;
//   //     }

//   //     if (isUserTokenFlow) {
//   //       await generateUserToken();
//   //     }
//   //     generateToken(paymentInitiation);
//   //   };
//   //   init();
//   // }, [dispatch, generateToken, generateUserToken, getInfo]);

//   // useEffect(() => {
//   //   fetchInstitutions();
//   // }, [fetchInstitutions]);

//   /// *** new stuff *** //
//   // const [linkToken, setLinkToken] = useState<string | null>(null);
//   // const [error, setError] = useState<string | null>(null);

//   // const generateLinkToken = useCallback(async () => {
//   //   try {
//   //     const response = await fetch(`${API_BASE_URL}/create_link_token`, {
//   //       method: "POST",
//   //       headers: {
//   //         "Content-Type": "application/json",
//   //       },
//   //     });

//   //     if (!response.ok) {
//   //       throw new Error("Failed to generate link token");
//   //     }

//   //     const data = await response.json();
//   //     const parsedBody = JSON.parse(data.body);

//   //     if (parsedBody.link_token) {
//   //       setLinkToken(parsedBody.link_token); // Save the link token
//   //       localStorage.setItem("link_token", parsedBody.link_token); // Save it for OAuth flow
//   //     } else {
//   //       throw new Error("Link token not found in response");
//   //     }
//   //   } catch (err: any) {
//   //     console.error("Error generating link token:", err);
//   //     setError(err.message || "An error occurred");
//   //   }
//   // }, []);

//   // // Fetch the link token when the component loads
//   // React.useEffect(() => {
//   //   generateLinkToken();
//   // }, [generateLinkToken]);

//   const handleSignOut = async () => {
//     try {
//       await amplifySignOut();
//       if (signOut) {
//         signOut();
//       }
//     } catch (error) {
//       console.error('Error signing out:', error);
//     }
//   };
//  // ** new stuff ** ////
//   return (
//     <div className="app-container">
//       <Sidebar />
//       <div className="main-content">
//         <div className="top-header">
//           <div className="header-content">
//             <h1>Welcome, {user?.username}</h1>
//             <button 
//               className="signin-button"
//               onClick={handleSignOut}
//             >
//               Sign out
//             </button>
//           </div>
//         </div>

//         <div className="dashboard-content">
//           <Header />
//           {linkSuccess && (
//             <>
//               <Institutions institutions={institutions} />
//               <Products />
//               {!isPaymentInitiation && itemId && (
//                 <>
//                   <Items />
//                   {/* <button onClick={simpleTransactionCall}>Get Transactions</button> */}
//                 </>
//               )}
//             </>
//           )}
//         </div>
//       </div>
//       <ChatWidget />
//     </div>
//   );
// };

// const simpleTransactionCall = async () => {
//   // call the local server to get the transactions
//   const response = await fetch("/api/transactions", { method: "GET" });
//   const data = await response.json();
//   console.log(`here is the data ${JSON.stringify(data)}`);

// };

const App = ({ signOut, user }: WithAuthenticatorProps) => {
  const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
    useContext(Context);
  const [linkToken, setLinkToken] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [institutions, setInstitutions] = useState([]);

  // Function to generate the Link Token
  const generateLinkToken = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/create_link_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Failed to generate link token");
      }

      const data = await response.json();
      const parsedBody = JSON.parse(data.body);

      if (parsedBody.link_token) {
        setLinkToken(parsedBody.link_token); // Save the link token
        localStorage.setItem("link_token", parsedBody.link_token); // Save it for OAuth flow
      } else {
        throw new Error("Link token not found in response");
      }
    } catch (err: any) {
      console.error("Error generating link token:", err);
      setError(err.message || "An error occurred");
    }
  }, []);

  // Fetch institutions
  const fetchInstitutions = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/institutions`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Failed to fetch institutions");
      }

      const data = await response.json();
      setInstitutions(data.institutions);
    } catch (error) {
      console.error("Error fetching institutions:", error);
    }
  }, []);

  // Fetch the link token when the component loads
  useEffect(() => {
    generateLinkToken();
    fetchInstitutions();
  }, [generateLinkToken, fetchInstitutions]);

  const handleSignOut = async () => {
    try {
      await amplifySignOut();
      if (signOut) {
        signOut();
      }
    } catch (error) {
      console.error("Error signing out:", error);
    }
  };

  return (
    <div className="app-container">
      <Sidebar />
      <div className="main-content">
        <div className="top-header">
          <div className="header-content">
            <h1>Welcome, {user?.username}</h1>
            <button className="signin-button" onClick={handleSignOut}>
              Sign out
            </button>
          </div>
        </div>

        <div className="dashboard-content">
          <Header />
          {error && <p style={{ color: "red" }}>Error: {error}</p>}
          {!linkToken && <p>Loading Link UI...</p>}
          {linkToken && (
            <div>
              <p>Link Token Generated Successfully!</p>
              <PlaidLink linkToken={linkToken} />
            </div>
          )}
            <Institutions institutions={institutions} />
            <Products />
            {!isPaymentInitiation && itemId && (
            <>
              <Items />
              {/* <button onClick={simpleTransactionCall}>Get Transactions</button> */}
            </>
            )}
        </div>
      </div>
      <ChatWidget />
    </div>
  );
};

// Plaid Link Component
const PlaidLink = ({ linkToken }: { linkToken: string }) => {
  const onSuccess = (publicToken: string, metadata: any) => {
    console.log("Public Token:", publicToken);
    console.log("Metadata:", metadata);
    // Send the public token to your backend for further processing
  };

  const config = {
    token: linkToken, // The link token generated from your backend
    onSuccess, // Callback function when the user successfully links their account
  };

  const { open, ready } = usePlaidLink(config);

  return (
    <button onClick={() => open()} disabled={!ready}>
      Open Plaid Link
    </button>
  );
};

export default withAuthenticator(App);