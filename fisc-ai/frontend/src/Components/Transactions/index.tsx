import React, { useEffect, useState } from 'react';

interface Transaction {
  date: string;
  name: string;
  amount: number;
  category: string[];
}

interface TransactionsProps {
  accessToken: string;
  API_BASE_URL: string;
}

const Transactions = ({ accessToken, API_BASE_URL }: TransactionsProps) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchTransactions = async () => {
    setIsLoading(true);
    setError(null);

    try {
      console.log('Fetching transactions with token:', accessToken); // Debug log

      const response = await fetch(
        `${API_BASE_URL}/create_transaction?access_token=${accessToken}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (!response.ok) {
        const errorData = await response.text();
        console.error('Response error:', errorData); // Debug log
        throw new Error(`Failed to fetch: ${response.status} ${response.statusText}`);
      }
      const data = await response.json();
      console.log('Response data:', data); // Debug log

      // Handle both parsed and unparsed responses
      const transactions = data.body ? JSON.parse(data.body).transactions : data.transactions;
      
      if (transactions) {
        console.log('Parsed transactions:', transactions); // Debug log
        setTransactions(transactions);
      } else {
        throw new Error('No transactions found in response');
      }
    } catch (error) {
      console.error('Error in fetchTransactions:', error);
      setError(error instanceof Error ? error.message : 'Failed to fetch transactions');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [accessToken]);

  return (
    <div className="transactions-container">
      <div className="transactions-header">
        <div style={{
          padding: '10px',
          backgroundColor: '#e6ffe6',
          borderRadius: '4px',
          marginBottom: '20px'
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
        <h2>Your Transactions</h2>
        <button 
          onClick={fetchTransactions}
          className="refresh-button"
          disabled={isLoading}
          style={{
            padding: '8px 16px',
            backgroundColor: isLoading ? '#cccccc' : '#4CAF50',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: isLoading ? 'not-allowed' : 'pointer'
          }}
        >
          {isLoading ? 'Loading...' : 'Refresh Transactions'}
        </button>
      </div>

      {error && (
        <div style={{ 
          color: 'red', 
          padding: '10px', 
          margin: '10px 0',
          backgroundColor: '#ffebee',
          borderRadius: '4px' 
        }}>
          Error: {error}
        </div>
      )}

      {isLoading ? (
        <div style={{ textAlign: 'center', padding: '20px' }}>
          Loading transactions...
        </div>
      ) : transactions.length > 0 ? (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ 
            width: '100%', 
            borderCollapse: 'collapse',
            marginTop: '20px'
          }}>
            <thead>
              <tr>
                <th style={tableHeaderStyle}>Date</th>
                <th style={tableHeaderStyle}>Name</th>
                <th style={tableHeaderStyle}>Amount</th>
                <th style={tableHeaderStyle}>Category</th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((transaction, index) => (
                <tr key={index} style={tableRowStyle}>
                  <td style={tableCellStyle}>{transaction.date}</td>
                  <td style={tableCellStyle}>{transaction.name}</td>
                  <td style={tableCellStyle}>${Math.abs(transaction.amount).toFixed(2)}</td>
                  <td style={tableCellStyle}>{transaction.category?.join(', ')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
          No transactions found
        </div>
      )}
    </div>
  );
};

const tableHeaderStyle = {
  backgroundColor: '#f5f5f5',
  padding: '12px',
  textAlign: 'left' as const,
  borderBottom: '2px solid #ddd'
};

const tableRowStyle = {
  borderBottom: '1px solid #ddd'
};

const tableCellStyle = {
  padding: '12px',
  textAlign: 'left' as const
};

export default Transactions; 