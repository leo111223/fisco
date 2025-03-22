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

Amplify.configure(awsconfig);

const App = ({ signOut, user }: WithAuthenticatorProps) => {
  const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
    useContext(Context);
  const [institutions, setInstitutions] = useState([]);

  const getInfo = useCallback(async () => {
    const response = await fetch("/api/info", { method: "POST" });
    if (!response.ok) {
      dispatch({ type: "SET_STATE", state: { backend: false } });
      return { paymentInitiation: false };
    }
    const data = await response.json();
    const paymentInitiation: boolean =
      data.products.includes("payment_initiation");
    const craEnumValues = Object.values(CraCheckReportProduct);
    const isUserTokenFlow: boolean = data.products.some(
      (product: CraCheckReportProduct) => craEnumValues.includes(product)
    );
    const isCraProductsExclusively: boolean = data.products.every(
      (product: CraCheckReportProduct) => craEnumValues.includes(product)
    );
    dispatch({
      type: "SET_STATE",
      state: {
        products: data.products,
        isPaymentInitiation: paymentInitiation,
        isCraProductsExclusively: isCraProductsExclusively,
        isUserTokenFlow: isUserTokenFlow,
      },
    });
    return { paymentInitiation, isUserTokenFlow };
  }, [dispatch]);

  const generateUserToken = useCallback(async () => { // these are to the local server on Port 8000 not the Plaid API. Only the LinkWidget is connected to the Plaid API
    const response = await fetch("api/create_user_token", { method: "POST" });
    if (!response.ok) {
      dispatch({ type: "SET_STATE", state: { userToken: null } });
      return;
    }
    const data = await response.json();
    if (data) {
      if (data.error != null) {
        dispatch({
          type: "SET_STATE",
          state: {
            linkToken: null,
            linkTokenError: data.error,
          },
        });
        return;
      }
      dispatch({ type: "SET_STATE", state: { userToken: data.user_token } });
      return data.user_token;
    }
  }, [dispatch]);

  const generateToken = useCallback(
    async (isPaymentInitiation: boolean) => {
      // Link tokens for 'payment_initiation' use a different creation flow in your backend.
      const path = isPaymentInitiation
        ? "/api/create_link_token_for_payment"
        : "/api/create_link_token";
      const response = await fetch(path, {
        method: "POST",
      });
      if (!response.ok) {
        dispatch({ type: "SET_STATE", state: { linkToken: null } });
        return;
      }
      const data = await response.json();
      if (data) {
        if (data.error != null) {
          dispatch({
            type: "SET_STATE",
            state: {
              linkToken: null,
              linkTokenError: data.error,
            },
          });
          return;
        }
        dispatch({ type: "SET_STATE", state: { linkToken: data.link_token } });
      }
      // Save the link_token to be used later in the Oauth flow.
      localStorage.setItem("link_token", data.link_token);
    },
    [dispatch]
  );

  const fetchInstitutions = useCallback(async () => {
    try {
      const response = await fetch('/api/institutions', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });
      
      if (!response.ok) {
        throw new Error('Failed to fetch institutions');
      }
      
      const data = await response.json();
      setInstitutions(data.institutions);
    } catch (error) {
      console.error('Error fetching institutions:', error);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      const { paymentInitiation, isUserTokenFlow } = await getInfo(); // used to determine which path to take when generating token
      // do not generate a new token for OAuth redirect; instead
      // setLinkToken from localStorage
      if (window.location.href.includes("?oauth_state_id=")) {
        dispatch({
          type: "SET_STATE",
          state: {
            linkToken: localStorage.getItem("link_token"),
          },
        });
        return;
      }

      if (isUserTokenFlow) {
        await generateUserToken();
      }
      generateToken(paymentInitiation);
    };
    init();
  }, [dispatch, generateToken, generateUserToken, getInfo]);

  useEffect(() => {
    fetchInstitutions();
  }, [fetchInstitutions]);

  const handleSignOut = async () => {
    try {
      await amplifySignOut();
      if (signOut) {
        signOut();
      }
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  return (
    <div className="app-container">
      <Sidebar />
      <div className="main-content">
        <div className="top-header">
          <div className="header-content">
            <h1>Welcome, {user?.username}</h1>
            <button 
              className="signin-button"
              onClick={handleSignOut}
            >
              Sign out
            </button>
          </div>
        </div>

        <div className="dashboard-content">
          <Header />
          {linkSuccess && (
            <>
              <Institutions institutions={institutions} />
              <Products />
              {!isPaymentInitiation && itemId && (
                <>
                  <Items />
                  <button onClick={simpleTransactionCall}>Get Transactions</button>
                </>
              )}
            </>
          )}
        </div>
      </div>
      <ChatWidget />
    </div>
  );
};

const simpleTransactionCall = async () => {
  // call the local server to get the transactions
  const response = await fetch("/api/transactions", { method: "GET" });
  const data = await response.json();
  console.log(`here is the data ${JSON.stringify(data)}`);

};

export default withAuthenticator(App);
