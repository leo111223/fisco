import { Table, TableHead, TableRow, TableCell, TableBody } from '@aws-amplify/ui-react';
import Institution from './Institution';
import './Institutions.css';

export interface InstitutionData {
  institution_id: string;
  name: string;
  // Add other fields you expect from Plaid
  logo?: string;
  products?: string[];
  status?: string;
}

interface InstitutionsProps {
  institutions: InstitutionData[];
}

export default function Institutions({ institutions = [] }: InstitutionsProps) {
  return (
    <div className="institutions-container">
      <h2>Connected Banks</h2>
      <Table highlightOnHover={true} variation="striped">
        <TableHead>
          <TableRow>
            <TableCell as="th">Institution</TableCell>
            <TableCell as="th">Status</TableCell>
            <TableCell as="th">Products</TableCell>
            <TableCell as="th">Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {institutions.length ? (
            institutions.map((institution) => (
              <Institution 
                key={institution.institution_id} 
                institution={institution}
              />
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={4}>No institutions connected</TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
} 