import React, { useState, useEffect } from 'react';
import styles from './Analytics.module.css';
import {
  PieChart, Pie, Cell, ResponsiveContainer,
  Tooltip, LineChart, Line, XAxis, YAxis,
  CartesianGrid, Legend
} from 'recharts';
// import {
//   PieChart, Pie, Cell, ResponsiveContainer,
//   Tooltip, LineChart, Line, XAxis, YAxis,
//   CartesianGrid, Legend
// } from 'recharts';

interface Transaction {
  account_id: string;
  amount: number;
  date: string;
  name: string;
  transaction_id: string;
  personal_finance_category?: {
    primary: string;
    detailed?: string;
  };
}

interface AnalyticsProps {
  accessToken: string;
  API_BASE_URL: string;
  userId: string;
}

interface BudgetStatus {
  class: 'success' | 'warning' | 'error';
  text: string;
}

interface DateRange {
  start: string;
  end: string;
}

const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#6366F1', '#14B8A6'];

const Analytics: React.FC<AnalyticsProps> = ({ accessToken, API_BASE_URL, userId }) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [filteredTransactions, setFilteredTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [monthlyBudget, setMonthlyBudget] = useState(5000); // Default budget
  const [dateRange, setDateRange] = useState<DateRange>({ start: '', end: '' });

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        setIsLoading(true);
        
        const response = await fetch(`${API_BASE_URL}/fetch_transactions_dynamo`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${accessToken}`
          }
        });

        if (!response.ok) {
          throw new Error('Failed to fetch transactions');
        }

        const data = await response.json();
        setTransactions(data.transactions || []);
        setFilteredTransactions(data.transactions || []);
      } catch (error) {
        console.error('Error fetching analytics:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchAnalytics();
  }, [API_BASE_URL, accessToken]);

  useEffect(() => {
    if (dateRange.start && dateRange.end) {
      const filtered = transactions.filter(t => {
        const transactionDate = new Date(t.date);
        const startDate = new Date(dateRange.start);
        const endDate = new Date(dateRange.end);
        return transactionDate >= startDate && transactionDate <= endDate;
      });
      setFilteredTransactions(filtered);
    } else {
      setFilteredTransactions(transactions);
    }
  }, [dateRange, transactions]);

  const handleDateRangeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setDateRange(prev => ({ ...prev, [name]: value }));
  };

  const resetDateRange = () => {
    setDateRange({ start: '', end: '' });
  };

  const calculateSummaries = () => {
    if (!filteredTransactions.length) return {
      totalSpending: 0,
      totalIncome: 0,
      monthlySpendingAverage: 0,
      monthlyIncomeAverage: 0,
      monthOverMonthChange: 0,
      budgetStatus: { class: 'warning' as const, text: 'No Data' },
      categoryTotals: []
    };

    // Separate transactions into expenses and income
    const expenses = filteredTransactions.filter(t => t.amount < 0);
    const income = filteredTransactions.filter(t => t.amount >= 0);

    // Calculate category totals for expenses only
    const categoryMap = new Map<string, number>();
    const totalSpending = expenses.reduce((sum, t) => {
      const amount = Math.abs(t.amount);
      const category = t.personal_finance_category?.primary || 'Other';
      categoryMap.set(category, (categoryMap.get(category) || 0) + amount);
      return sum + amount;
    }, 0);

    const totalIncome = income.reduce((sum, t) => sum + t.amount, 0);

    // Monthly calculations for expenses only
    const monthlySpending = new Map<string, number>();
    const monthlyIncome = new Map<string, number>();

    expenses.forEach(t => {
      const date = new Date(t.date);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      monthlySpending.set(monthKey, (monthlySpending.get(monthKey) || 0) + Math.abs(t.amount));
    });

    income.forEach(t => {
      const date = new Date(t.date);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      monthlyIncome.set(monthKey, (monthlyIncome.get(monthKey) || 0) + t.amount);
    });

    // Calculate month over month change
    const today = new Date();
    const currentMonth = today.getMonth();
    const currentYear = today.getFullYear();
    const currentMonthKey = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}`;
    const prevMonthKey = currentMonth === 0 
      ? `${currentYear - 1}-12`
      : `${currentYear}-${String(currentMonth).padStart(2, '0')}`;

    const currentMonthSpending = monthlySpending.get(currentMonthKey) || 0;
    const prevMonthSpending = monthlySpending.get(prevMonthKey) || 0;
    const monthOverMonthChange = prevMonthSpending 
      ? ((currentMonthSpending - prevMonthSpending) / prevMonthSpending) * 100
      : 0;

    // Calculate monthly average
    const monthlyAverage = Array.from(monthlySpending.values()).reduce((sum, amount) => sum + amount, 0) 
      / monthlySpending.size;

    // Determine budget status
    const daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
    const expectedSpending = (monthlyBudget / daysInMonth) * today.getDate();
    let budgetStatus: BudgetStatus = { class: 'warning', text: 'Near Budget' };
    if (currentMonthSpending <= expectedSpending * 0.9) {
      budgetStatus = { class: 'success', text: 'On Track' };
    } else if (currentMonthSpending > expectedSpending * 1.1) {
      budgetStatus = { class: 'error', text: 'Over Budget' };
    }

    return {
      totalSpending,
      totalIncome,
      monthlySpendingAverage: monthlyAverage,
      monthlyIncomeAverage: Array.from(monthlyIncome.values()).reduce((sum, amount) => sum + amount, 0) / monthlyIncome.size,
      monthOverMonthChange,
      budgetStatus,
      categoryTotals: Array.from(categoryMap.entries())
        .map(([category, amount]) => [category, amount] as [string, number])
        .sort((a, b) => b[1] - a[1])
    };
  };

  const { 
    totalSpending,
    totalIncome,
    monthlySpendingAverage,
    monthlyIncomeAverage,
    monthOverMonthChange,
    budgetStatus,
    categoryTotals 
  } = calculateSummaries();
  
  const renderCashFlowPieCharts = () => {
    // Separate transactions into income and expenses
    const incomeTransactions = filteredTransactions.filter(t => t.amount > 0);
    const expenseTransactions = filteredTransactions.filter(t => t.amount < 0);

    // Calculate category totals for income
    const incomeCategoryMap = new Map<string, number>();
    const totalIncome = incomeTransactions.reduce((sum, t) => {
      const category = t.personal_finance_category?.primary || 'Other';
      const amount = t.amount;
      incomeCategoryMap.set(category, (incomeCategoryMap.get(category) || 0) + amount);
      return sum + amount;
    }, 0);

    // Calculate category totals for expenses
    const expenseCategoryMap = new Map<string, number>();
    const totalExpenses = expenseTransactions.reduce((sum, t) => {
      const category = t.personal_finance_category?.primary || 'Other';
      const amount = Math.abs(t.amount);
      expenseCategoryMap.set(category, (expenseCategoryMap.get(category) || 0) + amount);
      return sum + amount;
    }, 0);

    // Prepare data for pie charts
    const incomePieData = Array.from(incomeCategoryMap.entries())
      .map(([category, amount]) => ({
        name: category,
        value: amount,
        percentage: (amount / totalIncome * 100).toFixed(2)
      }))
      .sort((a, b) => b.value - a.value);

    const expensePieData = Array.from(expenseCategoryMap.entries())
      .map(([category, amount]) => ({
        name: category,
        value: amount,
        percentage: (amount / totalExpenses * 100).toFixed(2)
      }))
      .sort((a, b) => b.value - a.value);

    const renderCustomizedLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent, name, value }: any) => {
      const RADIAN = Math.PI / 180;
      const radius = outerRadius + 35;
      const x = cx + radius * Math.cos(-midAngle * RADIAN);
      const y = cy + radius * Math.sin(-midAngle * RADIAN);
      
      if (percent < 0.02) return null;

      return (
        <g>
          <path
            d={`M${cx + (outerRadius + 10) * Math.cos(-midAngle * RADIAN)},${
              cy + (outerRadius + 10) * Math.sin(-midAngle * RADIAN)
            }L${x},${y}`}
            stroke="#64748b"
            strokeWidth={1}
            fill="none"
          />
          <text
            x={x}
            y={y}
            textAnchor={x > cx ? 'start' : 'end'}
            dominantBaseline="central"
            style={{ 
              fontSize: '13px',
              fontWeight: 500,
              fill: '#334155',
              letterSpacing: '0.01em'
            }}
          >
            <tspan x={x} dy="-0.5em">{name}</tspan>
            <tspan x={x} dy="1.5em" style={{ fontSize: '12px', fill: '#64748b' }}>
              ${value.toLocaleString()}
            </tspan>
          </text>
        </g>
      );
    };

    return (
      <div className={styles.fullWidthChart}>
        <div className={styles.pieChartsColumn}>
          {/* Income Pie Chart */}
          <div className={`${styles.pieChartSection} ${styles.incomePieChart}`}>
            <h3>Money Received</h3>
            <div className={styles.chartContainer}>
              <div className={styles.totalAmount}>
                <div className={styles.label}>Total Income</div>
                <div className={styles.value}>${totalIncome.toLocaleString()}</div>
              </div>
              <ResponsiveContainer width="100%" height={500}>
                <PieChart>
                  <Pie
                    data={incomePieData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={renderCustomizedLabel}
                    outerRadius={160}
                    innerRadius={100}
                    fill="#8884d8"
                    dataKey="value"
                    paddingAngle={4}
                    startAngle={90}
                    endAngle={-270}
                  >
                    {incomePieData.map((entry, index) => (
                      <Cell 
                        key={`income-cell-${index}`} 
                        fill={COLORS[index % COLORS.length]}
                        stroke="#fff"
                        strokeWidth={2}
                      />
                    ))}
                  </Pie>
                  <Tooltip 
                    formatter={(value: number, name: string) => [
                      `$${value.toLocaleString()}`,
                      name
                    ]}
                    contentStyle={{
                      backgroundColor: '#fff',
                      border: 'none',
                      borderRadius: '12px',
                      boxShadow: '0 4px 16px rgba(0,0,0,0.08)',
                      padding: '12px 16px',
                      fontSize: '14px'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Expenses Pie Chart */}
          <div className={styles.pieChartSection}>
            <h3>Money Spent</h3>
            <div className={styles.chartContainer}>
              <div className={styles.totalAmount}>
                <div className={styles.label}>Total Expenses</div>
                <div className={styles.value}>${totalSpending.toLocaleString()}</div>
              </div>
              <ResponsiveContainer width="100%" height={450}>
                <PieChart>
                  <Pie
                    data={expensePieData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={renderCustomizedLabel}
                    outerRadius={140}
                    innerRadius={85}
                    fill="#8884d8"
                    dataKey="value"
                    paddingAngle={4}
                    startAngle={90}
                    endAngle={-270}
                  >
                    {expensePieData.map((entry, index) => (
                      <Cell 
                        key={`expense-cell-${index}`} 
                        fill={COLORS[index % COLORS.length]}
                        stroke="#fff"
                        strokeWidth={2}
                      />
                    ))}
                  </Pie>
                  <Tooltip 
                    formatter={(value: number, name: string) => [
                      `$${value.toLocaleString()}`,
                      name
                    ]}
                    contentStyle={{
                      backgroundColor: '#fff',
                      border: 'none',
                      borderRadius: '12px',
                      boxShadow: '0 4px 16px rgba(0,0,0,0.08)',
                      padding: '12px 16px',
                      fontSize: '14px'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>
    );
  };

  const renderMonthlySpendingChart = () => {
    const monthlyData = new Map<string, number>();
    
    // Group transactions by month
    filteredTransactions.forEach(t => {
      const date = new Date(t.date);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      monthlyData.set(monthKey, (monthlyData.get(monthKey) || 0) + Math.abs(t.amount));
    });

    // Convert to array and sort by date
    const lineData = Array.from(monthlyData.entries())
      .map(([month, amount]) => ({
        month,
        amount
      }))
      .sort((a, b) => a.month.localeCompare(b.month));

    // Commenting out Monthly Spending Chart for now
    return null;
    /*return (
      <div className={styles.chartCard}>
        <h3>Monthly Spending Trends</h3>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={lineData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis 
              dataKey="month" 
              tickFormatter={(value) => {
                const [year, month] = value.split('-');
                return `${new Date(parseInt(year), parseInt(month)-1).toLocaleString('default', { month: 'short' })}`;
              }}
            />
            <YAxis 
              tickFormatter={(value) => `$${value.toLocaleString()}`}
            />
            <Tooltip 
              formatter={(value: any) => `$${Number(value).toLocaleString()}`}
            />
            <Legend />
            <Line 
              type="monotone" 
              dataKey="amount" 
              stroke="#8884d8" 
              name="Monthly Spending"
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    );*/
  };

  if (isLoading) {
    return <div className={styles.loadingState}>Loading analytics...</div>;
  }

  return (
    <div className={styles.analyticsContainer}>
      <div style={{ marginBottom: '20px', padding: '15px', background: 'white', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', justifyContent: 'center' }}>
          <input
            type="date"
            name="start"
            value={dateRange.start}
            onChange={handleDateRangeChange}
            style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
          />
          <span>to</span>
          <input
            type="date"
            name="end"
            value={dateRange.end}
            onChange={handleDateRangeChange}
            style={{ padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
          />
          <button 
            onClick={resetDateRange}
            style={{ 
              padding: '8px 16px', 
              background: '#f0f0f0', 
              border: '1px solid #ddd', 
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Reset to All Time
          </button>
        </div>
      </div>
      <div className={styles.analyticsGrid}>
        {/* Key Metrics */}
        <div className={styles.metricsCard}>
          <div className={styles.metricLabel}>Total Income</div>
          <div className={styles.metricValue}>${totalIncome.toLocaleString()}</div>
        </div>

        <div className={styles.metricsCard}>
          <div className={styles.metricLabel}>Total Expenses</div>
          <div className={styles.metricValue}>${totalSpending.toLocaleString()}</div>
        </div>

        <div className={styles.metricsCard}>
          <div className={styles.metricLabel}>Monthly Average</div>
          <div className={styles.metricValue}>${monthlySpendingAverage.toLocaleString()}</div>
        </div>

        <div className={styles.metricsCard}>
          <div className={styles.metricLabel}>Budget Status</div>
          <div className={`${styles.metricValue} ${styles[budgetStatus.class]}`}>
            {budgetStatus.text}
          </div>
        </div>

        {/* Pie Charts */}
        {renderCashFlowPieCharts()}
        
        {/* Monthly Spending Chart */}
        {renderMonthlySpendingChart()}
      </div>
    </div>
  );
};

export default Analytics;
