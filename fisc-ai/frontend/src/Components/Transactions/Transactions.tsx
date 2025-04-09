import React from 'react';
import { Table, TableHead, TableRow, TableCell, TableBody } from '@aws-amplify/ui-react';

interface Counterparty {
  name: string;
  type: string;
  website: string | null;
  logo_url: string | null;
  confidence_level: string;
  entity_id: string | null;
  phone_number: string | null;
}

interface Transaction {
  account_id: string;
  amount: number;
  category: string[];
  date: string;
  merchant_name: string | null;
  name: string;
  payment_channel: string;
  pending: boolean;
  transaction_type: string;
  logo_url: string | null;
  transaction_id: string;
  counterparties: Counterparty[];
  personal_finance_category: {
    primary: string;
    detailed: string;
    confidence_level: string;
  };
}

interface TransactionsProps {
  transactions: Transaction[];
}

const Transactions: React.FC<TransactionsProps> = ({ transactions = [] }) => {
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

  return (
    <div className="transactions-container">
      <h2>Recent Transactions</h2>
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
              <TableRow key={transaction.transaction_id}>
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
                <TableCell>{transaction.personal_finance_category.primary}</TableCell>
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
    </div>
  );
};

export default Transactions;