import { TableRow, TableCell, Button } from '@aws-amplify/ui-react';
import { InstitutionData } from './index';

interface InstitutionProps {
  institution: InstitutionData;
}

export default function Institution({ institution }: InstitutionProps) {
  const handleViewDetails = () => {
    // TODO: Implement view details functionality
    console.log('View details for:', institution.institution_id);
  };

  const handleDisconnect = async () => {
    // TODO: Implement disconnect functionality
    console.log('Disconnect:', institution.institution_id);
  };

  return (
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
            <span key={product} className="product-badge">
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
            View Details
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
  );
} 