import React, { useEffect, useContext, useCallback, useState } from "react";
import { signOut as amplifySignOut } from '@aws-amplify/auth';

import Header from "./Components/Headers";
import Products from "./Components/ProductTypes/Products";
import Items from "./Components/ProductTypes/Items";
import Context from "./Context";
import Sidebar from './Components/Sidebar';
import ChatWidget from './Components/ChatWidget';
import Institutions from './Components/Institutions';
import Transactions from './Components/Transactions';
import Dashboard from './views/Dashboard';

import { CraCheckReportProduct } from "plaid";
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';
import type { WithAuthenticatorProps } from '@aws-amplify/ui-react';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import './App.css';
import { usePlaidLink } from "react-plaid-link";
Amplify.configure(awsconfig);
export const API_BASE_URL = "https://wyf57xwv9l.execute-api.us-east-1.amazonaws.com/prod"; // currently functional API base URL

const App = ({ signOut, user }: WithAuthenticatorProps) => {
  const { linkSuccess, isPaymentInitiation, itemId, dispatch } =
    useContext(Context);
  const [linkToken, setLinkToken] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [institutions, setInstitutions] = useState<Array<{
    institution_id: string;
    name: string;
    logo?: string | null;
    products?: string[];
    status?: string;
    accounts: any[];
  }>>([]);
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [activeView, setActiveView] = useState('dashboard');
  const [transactions, setTransactions] = useState([]);

  // First, create an initialization function
  const initializeApp = useCallback(async () => {
    try {
      console.log("🚀 Initializing app...");
      
      // Generate access token
      const accessTokenResponse = await fetch(`${API_BASE_URL}/access_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!accessTokenResponse.ok) {
        throw new Error("Failed to generate access token");
      }

      const accessTokenData = await accessTokenResponse.json();
      const parsedAccessData = JSON.parse(accessTokenData.body);
      const token = parsedAccessData.access_token || parsedAccessData.acess_token;
      
      if (token) {
        console.log("✅ Access token received:", token);
        setAccessToken(token);
        localStorage.setItem("access_token", token);
      }

      // Generate link token
      const linkTokenResponse = await fetch(`${API_BASE_URL}/linked_token`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!linkTokenResponse.ok) {
        throw new Error("Failed to generate link token");
      }

      const linkTokenData = await linkTokenResponse.json();
      const parsedLinkData = JSON.parse(linkTokenData.body);

      if (parsedLinkData.link_token) {
        console.log("✅ Link token received");
        setLinkToken(parsedLinkData.link_token);
        localStorage.setItem("link_token", parsedLinkData.link_token);
      }

      // Fetch transactions
      // if (token) {
      //   try {
      //     const transactionsResponse = await fetch(
      //       `${API_BASE_URL}/create_transaction?access_token=${token}`,
      //       {
      //         method: "POST",
      //         headers: {
      //           "Content-Type": "application/json",
      //         }
      //       }
      //     );

      //     if (!transactionsResponse.ok) {
      //       const errorData = await transactionsResponse.json();
      //       console.error("Transaction fetch error:", errorData);
      //       throw new Error(`Failed to fetch transactions: ${errorData.error || transactionsResponse.statusText}`);
      //     }

      //     const transactionsData = await transactionsResponse.json();
      //     console.log("✅ Transactions fetched:", transactionsData);
          
      //     // Check if the response has the expected structure
      //     if (transactionsData.transactions) {
      //       setTransactions(transactionsData.transactions);
      //     } else {
      //       console.error("Unexpected response structure:", transactionsData);
      //       throw new Error("Invalid response format from server");
      //     }
      //   } catch (error) {
      //     console.error("Error fetching transactions:", error);
      //     setError(error instanceof Error ? error.message : "Failed to fetch transactions");
      //   }
      // }

      // Fetch institutions

      const getAccountsResponse = await fetch(`${API_BASE_URL}/get_accounts?access_token=${token}&user_id=${user?.username}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({}) // Empty body since data is in query params
      });

      if (!getAccountsResponse.ok) {
        throw new Error("Failed to fetch accounts");
      }

      const accountsData = await getAccountsResponse.json();
      console.log("✅ Accounts fetched");
      console.log(accountsData);
      
      // Group accounts by institution
      const institutionsMap = new Map();
      
      accountsData.accounts.accounts.forEach((account: any) => {
        const institutionId = account.institution_id || accountsData.accounts.item.institution_id;
        const institutionName = account.institution_name || accountsData.accounts.item.institution_name;
        
        if (!institutionsMap.has(institutionId)) {
          institutionsMap.set(institutionId, {
            institution_id: institutionId,
            name: institutionName,
            logo: null,
            products: account.products || accountsData.accounts.item.products || [],
            status: 'Connected',
            accounts: []
          });
        }
        institutionsMap.get(institutionId).accounts.push(account);
      });
      
      // Convert map to array
      const institutions = Array.from(institutionsMap.values());
      console.log("Transformed institutions:", institutions);
      
      setInstitutions(institutions);

    } catch (error) {
      console.error("Error:", error);
      setError(error instanceof Error ? error.message : "An error occurred during initialization");
    }
  }, []);

  // Single useEffect for initialization
  useEffect(() => {
    initializeApp();
  }, [initializeApp]);

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

  const renderContent = () => {
    switch (activeView) {
      case 'dashboard':
        return (
          <Dashboard 
            error={error}
            linkToken={linkToken}
            accessToken={accessToken}
            setAccessToken={setAccessToken}
            API_BASE_URL={API_BASE_URL}
          />
        );

      case 'transactions':
        return (
          <div className="view-container">
            <h2>Transactions</h2>
            {accessToken ? (
              <Transactions 
                accessToken={accessToken}
                API_BASE_URL={API_BASE_URL}
                userId={user?.username || ''}
              />
            ) : (
              <p>Please wait while we connect to your bank account...</p>
            )}
          </div>
        );

      case 'bank-accounts':
        return (
          <div className="view-container">
            <Institutions institutions={institutions} />
          </div>
        );

      case 'analytics':
        return (
          <div className="view-container">
            <h2>Analytics</h2>
            {/* Add your analytics component here */}
          </div>
        );

      case 'profile':
        return (
          <div className="view-container">
            <h2>Profile</h2>
            <div className="profile-info">
              <p>Username: {user?.username}</p>
              {/* Add more profile information */}
            </div>
          </div>
        );

      case 'settings':
        return (
          <div className="view-container">
            <h2>Settings</h2>
            {/* Add your settings component here */}
          </div>
        );

      default:
        return <div>Page not found</div>;
    }
  };

  return (
    <div className="app-container">
      <Sidebar 
        activeView={activeView}
        onNavigate={setActiveView}
      />
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
          {renderContent()}
        </div>
      </div>
      <ChatWidget />
    </div>
  );
};

export default withAuthenticator(App);
