import React, { useState } from 'react';
import { Card, Heading, Flex, Text, View, Button, Badge, Grid } from '@aws-amplify/ui-react';
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
    <View padding="20px">
      <Card variation="elevated">
        <Heading level={1} padding="20px">
          Welcome to FiscAI
        </Heading>

        {/* How It Works Section */}
        <Card variation="outlined" padding="20px" marginBottom="20px">
          <Heading level={3} marginBottom="15px">
            How It Works
          </Heading>
          <Grid templateColumns="1fr 1fr 1fr" gap="20px">
            <Card padding="15px" textAlign="center">
              <Text fontSize="24px" marginBottom="10px">🔒</Text>
              <Heading level={5}>1. Secure Connection</Heading>
              <Text>
                Connect your bank securely using Plaid's trusted platform, used by millions worldwide.
              </Text>
            </Card>
            <Card padding="15px" textAlign="center">
              <Text fontSize="24px" marginBottom="10px">📊</Text>
              <Heading level={5}>2. Smart Analysis</Heading>
              <Text>
                FiscAI analyzes your transactions and provides AI-powered insights to help you manage your money better.
              </Text>
            </Card>
            <Card padding="15px" textAlign="center">
              <Text fontSize="24px" marginBottom="10px">💡</Text>
              <Heading level={5}>3. AI Assistant</Heading>
              <Text>
                Query your financial data in natural language to get answers.
              </Text>
            </Card>
          </Grid>
        </Card>

        {/* Plaid's Security Promise */}
        <Card variation="outlined" padding="20px" marginBottom="20px" backgroundColor="rgba(0, 128, 0, 0.05)">
          <Flex alignItems="center" gap="15px">
            <Text fontSize="24px">🛡️</Text>
            <div>
              <Heading level={4} marginBottom="10px">
                Plaid's Security Promise
              </Heading>
              <Text>
                Your security is our top priority. We use Plaid, a trusted financial services platform that:
              </Text>
              <Grid templateColumns="1fr 1fr" gap="10px" marginTop="10px">
                <Flex alignItems="center" gap="5px">
                  <Text>✓</Text>
                  <Text>Uses bank-level encryption</Text>
                </Flex>
                <Flex alignItems="center" gap="5px">
                  <Text>✓</Text>
                  <Text>Never stores your credentials</Text>
                </Flex>
                <Flex alignItems="center" gap="5px">
                  <Text>✓</Text>
                  <Text>Regularly audited for security</Text>
                </Flex>
                <Flex alignItems="center" gap="5px">
                  <Text>✓</Text>
                  <Text>Used by major financial apps</Text>
                </Flex>
              </Grid>
            </div>
          </Flex>
        </Card>

        {/* Plaid Connection Section */}
        <Card variation="outlined" padding="20px" marginBottom="20px">
          <Heading level={3} marginBottom="15px">
            Connect Your Bank Account
          </Heading>
          
          {!linkToken ? (
            <Flex direction="column" alignItems="center" padding="20px">
              <Text variation="warning">Loading Plaid Link...</Text>
              {/* Add a loading spinner here */}
            </Flex>
          ) : (
            <Flex direction="column" gap="15px">
              <Text>
                Securely connect your bank account to start tracking your transactions
                and managing your finances with AI-powered Features.
              </Text>
              <PlaidLink 
                linkToken={linkToken} 
                setAccessToken={setAccessToken}
                API_BASE_URL={API_BASE_URL}
                setPublicToken={setPublicToken}
              />
            </Flex>
          )}
        </Card>

        {/* Features Preview */}
        <Flex direction="row" gap="20px" wrap="wrap">
          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>Transaction Analysis</Heading>
            <Text>
              View and analyze your recent transactions across all your accounts.
            </Text>
          </Card>

          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>Receipt Processing</Heading>
            <Text>
              Upload receipts for automatic data extraction and transaction
              matching.
            </Text>
          </Card>

          <Card variation="outlined" padding="20px" flex="1" minWidth="250px">
            <Heading level={4}>AI Assistant</Heading>
            <Text>
              Query your financial data in natural language to get answers.
            </Text>
          </Card>
        </Flex>

        {/* Debug Information (Collapsible) */}
        {/* Commenting out access token details for security
        {(publicToken || accessToken) && ( */}
        {(publicToken) && (
          <Card 
            variation="outlined" 
            padding="20px" 
            marginTop="20px"
            backgroundColor="#f8f9fa"
          >
            <Heading level={4}>Connection Details</Heading>
            
            {publicToken && (
              <View 
                padding="10px" 
                backgroundColor="#e6f7ff"
                borderRadius="4px"
                marginBottom="10px"
              >
                <Text fontWeight="bold">🔑 Public Token</Text>
                <Text 
                  fontSize="sm"
                  style={{ wordBreak: 'break-all' }}
                  padding="10px"
                  backgroundColor="white"
                  borderRadius="4px"
                >
                  {publicToken}
                </Text>
              </View>
            )}
            
            {accessToken && (
              <View 
                padding="10px" 
                backgroundColor="#e6ffe6"
                borderRadius="4px"
              >
                <Text fontWeight="bold">🔐 Access Token</Text>
                <Text 
                  fontSize="sm"
                  style={{ wordBreak: 'break-all' }}
                  padding="10px"
                  backgroundColor="white"
                  borderRadius="4px"
                >
                  {accessToken}
                </Text>
              </View>
            )}
          </Card>
        )}
      </Card>
    </View>
  );
};

export default Dashboard; 