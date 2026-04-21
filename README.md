# Insurance Claims SQL Project

## Overview
This project analyses insurance customer risk and profitability using SQL on Azure.

## Tech Stack
- Python (pandas)
- Azure SQL Database
- SQL (T-SQL)
- CLI tools (sqlcmd, bcp)

## Data Processing
- Cleaned dataset using Python
- Created structured tables:
  - customers
  - policies
  - claims

## Key Questions
- Which customers generate the most claims?
- Are certain customers unprofitable?
- Do smokers have higher claim costs?

## Example Query
```sql
SELECT 
    c.smoker,
    AVG(cl.claim_amount) AS avg_claim
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY c.smoker;