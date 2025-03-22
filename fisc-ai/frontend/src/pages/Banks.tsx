import React from 'react';
import Institutions from '../Components/Institutions';

interface BanksProps {
  institutions: any[];
}

const Banks: React.FC<BanksProps> = ({ institutions }) => {
  return (
    <div className="page-container">
      <h1>Bank Accounts</h1>
      <Institutions institutions={institutions} />
    </div>
  );
};

export default Banks; 