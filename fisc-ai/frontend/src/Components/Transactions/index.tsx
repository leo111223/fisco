import React, { useEffect, useState } from 'react';
import styles from './Transactions.module.css';

interface Transaction {
  date: string;
  name: string;
  amount: number;
  category: string[];
  id?: string;
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

  // we need to fetch the transactions from the backend

  // const fetchTransactions = async () => {
  // try {
  //   const transactionsResponse = await fetch(
  //     `${API_BASE_URL}/create_transaction?access_token=${accessToken}&user_id=${userId}`,
  //     {
  //       method: "POST",
  //       headers: {
  //         "Content-Type": "application/json",
  //       }
  //     }
  //   );

  //   if (!transactionsResponse.ok) {
  //     const errorData = await transactionsResponse.json();
  //     console.error("Transaction fetch error:", errorData);
  //     throw new Error(`Failed to fetch transactions: ${errorData.error || transactionsResponse.statusText}`);
  //   }

  //   const transactionsData = await transactionsResponse.json();
  //   console.log("✅ Transactions fetched:", transactionsData);
    
  //   // Check if the response has the expected structure
  //   if (transactionsData.transactions) {
  //     setTransactions(transactionsData.transactions);
  //   } else {
  //     console.error("Unexpected response structure:", transactionsData);
  //     throw new Error("Invalid response format from server");
  //   }
  // } catch (error) {
  //   console.error("Error fetching transactions:", error);
  //   setError(error instanceof Error ? error.message : "Failed to fetch transactions");
  //   setIsLoading(false);
  // }
  // }
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
          <div className="access-token-container">
            <p>🔐 Access Token:</p>
            <p className="access-token">
              {accessToken}
            </p>
          </div>
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

      {/* Simple Upload Modal */}
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