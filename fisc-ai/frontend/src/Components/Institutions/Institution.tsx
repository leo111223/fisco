import { TableRow, TableCell, Button, Table, TableHead, TableBody } from '@aws-amplify/ui-react';
import { InstitutionData } from './index';
import { useState } from 'react';

interface InstitutionProps {
  institution: InstitutionData;
}

export default function Institution({ institution }: InstitutionProps) {
  const [showAccounts, setShowAccounts] = useState(false);

  const handleViewDetails = () => {
    setShowAccounts(!showAccounts);
  };

  const handleDisconnect = async () => {
    // TODO: Implement disconnect functionality
    console.log('Disconnect:', institution.institution_id);
  };

  return (
    <>
      <TableRow>
        <TableCell>
          <div className="institution-name">
            {institution.logo && (
              <img 
                src={institution.logo} 
                alt={`${institution.name} logo`} 
                className="institution-logo"
              />
            )}
            {institution.name}
          </div>
        </TableCell>
        <TableCell>
          <span className={`status-badge ${institution.status?.toLowerCase()}`}>
            {institution.status || 'Connected'}
          </span>
        </TableCell>
        <TableCell>
          <div className="products-list">
            {institution.products?.map((product) => (
              <span key={`product-${product}`} className="product-badge">
                {product}
              </span>
            ))}
          </div>
        </TableCell>
        <TableCell>
          <div className="action-buttons">
            <Button
              onClick={handleViewDetails}
              size="small"
              variation="primary"
            >
              {showAccounts ? 'Hide Accounts' : 'View Accounts'}
            </Button>
            <Button
              onClick={handleDisconnect}
              size="small"
              variation="destructive"
            >
              Disconnect
            </Button>
          </div>
        </TableCell>
      </TableRow>
      {showAccounts && institution.accounts && (
        <TableRow>
          <TableCell colSpan={4}>
            <Table variation="striped">
              <TableHead>
                <TableRow>
                  <TableCell as="th">Account Name</TableCell>
                  <TableCell as="th">Type</TableCell>
                  <TableCell as="th">Balance</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {institution.accounts.map((account) => (
                  <TableRow key={`account-${account.account_id}`}>
                    <TableCell>{account.name}</TableCell>
                    <TableCell>{account.type}</TableCell>
                    <TableCell>${account.balances?.current || 0}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableCell>
        </TableRow>
      )}
    </>
  );
} 