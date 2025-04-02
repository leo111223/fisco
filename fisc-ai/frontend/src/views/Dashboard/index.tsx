import React, { useState } from 'react';
import Header from '../../Components/Headers';
import PlaidLink from '../../Components/PlaidLink';

// Add interface for Dashboard props
interface DashboardProps {
  error: string | null;
  linkToken: string | null;
  accessToken: string | null;
  setAccessToken: (token: string) => void;
  API_BASE_URL: string;  // Add this prop
}

const Dashboard = ({ 
  error, 
  linkToken, 
  accessToken, 
  setAccessToken,
  API_BASE_URL  // Add this prop
}: DashboardProps) => {
  const [publicToken, setPublicToken] = useState<string | null>(null);

  return (
    <>
      {/* <Header /> */}

      
      {!linkToken ? (
        <p>Loading Plaid Link...</p>
      ) : (
        <div>
          <p>Ready to connect your bank account</p>
          <PlaidLink 
            linkToken={linkToken} 
            setAccessToken={setAccessToken}
            API_BASE_URL={API_BASE_URL}
            setPublicToken={setPublicToken}
          />
        </div>
      )}

      {/* Display both tokens in separate boxes */}
      <div style={{ marginTop: '20px' }}>
        {publicToken && (
          <div style={{ 
            padding: '10px', 
            backgroundColor: '#e6f7ff',
            marginBottom: '10px',
            borderRadius: '4px'
          }}>
            <p>🔑 Public Token:</p>
            <p style={{ 
              wordBreak: 'break-all', 
              padding: '10px', 
              backgroundColor: '#f0f0f0',
              borderRadius: '4px'
            }}>
              {publicToken}
            </p>
          </div>
        )}
        {!accessToken && (
          <p>No access token</p>
        )}
        {accessToken && (
          <div style={{ 
            padding: '10px', 
            backgroundColor: '#e6ffe6',
            borderRadius: '4px'
          }}>
            <p>🔐 Access Token:</p>
            <p style={{ 
              wordBreak: 'break-all', 
              padding: '10px', 
              backgroundColor: '#f0f0f0',
              borderRadius: '4px'
            }}>
              {accessToken}
            </p>
          </div>
        )}
      </div>
    </>
  );
};

export default Dashboard; 