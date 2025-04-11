import React, { useEffect, useState } from 'react';
import { Table, TableHead, TableRow, TableCell, TableBody } from '@aws-amplify/ui-react';
import styles from './Transactions.module.css';

interface Transaction {
  date: string;
  name: string;
  amount: number;
  category: string[];
  id?: string;
  merchant_name: string | null;
  logo_url: string | null;
  pending: boolean;
  personal_finance_category: {
    primary: string;
    detailed: string;
    confidence_level: string;
  };
}

interface Receipt {
  id: string;
  transactionId: string;
  fileName: string;
  url: string;
}

interface TransactionsProps {
  accessToken: string;
  API_BASE_URL: string;
  userId: string;
}

const Transactions = ({ accessToken, API_BASE_URL, userId }: TransactionsProps) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [receipts, setReceipts] = useState<Record<string, Receipt>>({});
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<string>('');

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: '2-digit', 
      year: 'numeric' 
    });
  };

  const fetchTransactions = async () => {
    try {
      setIsLoading(true);
      const transactionsResponse = await fetch(
        `${API_BASE_URL}/transactions?access_token=${accessToken}&user_id=${userId}`,
        {
          method: "POST", 
          headers: {
            "Content-Type": "application/json",
          }
        }
      );

      if (!transactionsResponse.ok) {
        const errorData = await transactionsResponse.json();
        console.error("Transaction fetch error:", errorData);
        throw new Error(`Failed to fetch transactions: ${errorData.error || transactionsResponse.statusText}`);
      }

      const transactionsData = await transactionsResponse.json();
      console.log("✅ Transactions fetched:", transactionsData);
      
      if (transactionsData.transactions) {
        setTransactions(transactionsData.transactions);
      } else {
        console.error("Unexpected response structure:", transactionsData);
        throw new Error("Invalid response format from server");
      }
    } catch (error) {
      console.error("Error fetching transactions:", error);
      setError(error instanceof Error ? error.message : "Failed to fetch transactions");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [accessToken, userId]);

  const handleReceiptUpload = async (file: File) => {
    try {
      const formData = new FormData();
      formData.append('receipt', file);

      const response = await fetch(`${API_BASE_URL}/upload-receipt`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`
        },
        body: formData
      });

      if (!response.ok) throw new Error('Upload failed');

      const data = await response.json();
      setUploadStatus('Receipt uploaded successfully! Processing with Textract...');
      setShowUploadModal(false);
    } catch (error) {
      setUploadStatus('Failed to upload receipt');
      console.error('Upload error:', error);
    }
  };

  return (
    <div className="transactions-container">
      <div className="transactions-header">
        <div className="header-left">
          {/* <div className="access-token-container">
            <p>🔐 Access Token:</p>
            <p className="access-token">{accessToken}</p>
          </div> */}
          <h2>Your Transactions</h2>
        </div>
        
        <div className="header-right">
          <button 
            onClick={() => setShowUploadModal(true)}
            className="upload-receipt-button"
          >
            📄 Upload Receipt
          </button>
        </div>
      </div>

      {isLoading ? (
        <p>Loading transactions...</p>
      ) : error ? (
        <p className="error-message">{error}</p>
      ) : (
        <Table highlightOnHover={true} variation="striped">
          <TableHead>
            <TableRow>
              <TableCell as="th">Date</TableCell>
              <TableCell as="th">Merchant</TableCell>
              <TableCell as="th">Category</TableCell>
              <TableCell as="th">Amount</TableCell>
              <TableCell as="th">Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {transactions.length ? (
              transactions.map((transaction) => (
                <TableRow key={transaction.id}>
                  <TableCell>{formatDate(transaction.date)}</TableCell>
                  <TableCell>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      {transaction.logo_url && (
                        <img
                          src={transaction.logo_url}
                          alt={transaction.merchant_name || transaction.name}
                          style={{ width: '24px', height: '24px', borderRadius: '50%' }}
                        />
                      )}
                      {transaction.merchant_name || transaction.name}
                    </div>
                  </TableCell>
                  <TableCell>{transaction.personal_finance_category?.primary || transaction.category[0]}</TableCell>
                  <TableCell style={{ color: transaction.amount < 0 ? '#d32f2f' : '#2e7d32' }}>
                    {formatAmount(transaction.amount)}
                  </TableCell>
                  <TableCell>{transaction.pending ? 'Pending' : 'Completed'}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={5}>No transactions found</TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      )}

      {showUploadModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3>Upload Receipt</h3>
            <div className="upload-section">
              <input
                type="file"
                accept="image/*,.pdf"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) {
                    handleReceiptUpload(file);
                  }
                }}
                className="file-input"
              />
              <button
                onClick={() => setShowUploadModal(false)}
                className="cancel-button"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {uploadStatus && (
        <div className={`notification ${uploadStatus.includes('success') ? 'success' : 'error'}`}>
          {uploadStatus}
        </div>
      )}
    </div>
  );
};

export default Transactions;