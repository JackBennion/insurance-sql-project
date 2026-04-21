# Insurance Claims Analytics Pipeline (Azure SQL and Python)

## Overview
This project implements a simple end-to-end data pipeline for analysing insurance claims data. A raw dataset is cleaned and transformed using Python, then structured into a relational model and loaded into an Azure SQL database. SQL is used to explore customer risk, claims behaviour, and overall profitability.

The aim is to demonstrate a practical workflow that mirrors how data might be handled in a real insurance analytics setting.

---

## Technologies Used
- Python (pandas, numpy)
- Azure SQL Database
- SQL (T-SQL)
- Command line tools (sqlcmd, bcp)
- Git and GitHub

---

## Dataset
The source dataset contains information on insurance policyholders, including:
- Age, sex, and region
- BMI and lifestyle indicators (e.g. smoking status, daily steps)
- Medical charges
- Claim indicator

From this dataset, additional tables were derived to reflect a more realistic system:
- Customers
- Policies
- Claims

---

## Data Processing
Data preparation is handled in Python. The main steps include:
- Standardising column names
- Validating categorical fields
- Creating unique identifiers
- Deriving additional fields such as premiums and claims

The output of this stage is three CSV files:
- `customers.csv`
- `policies.csv`
- `claims.csv`

These files form the basis of the relational model.

---

## Data Model
The data is structured into three tables:

**customers**
- customer_id (primary key)
- demographic and health attributes

**policies**
- policy_id (primary key)
- customer_id (foreign key)
- premium_amount

**claims**
- claim_id (primary key)
- policy_id (foreign key)
- claim_amount
- claim_status

This structure allows for straightforward joins and analysis across customers, policies, and claims.

---

## Azure SQL Setup
The processed data is loaded into an Azure SQL database using command line tools:
- Tables are created using SQL DDL
- Data is inserted using `bcp`
- Queries are executed via `sqlcmd`

This setup reflects a simple cloud-based data workflow.

---

## Analysis
SQL queries are provided in `sql/analysis.sql`.

The analysis focuses on questions such as:
- Which policies generate the highest claim volumes?
- Which customers are unprofitable?
- How does smoking status affect claim cost?
- Are there regional differences in risk?
- What proportion of claims are approved?

Example:

```sql
SELECT 
    c.smoker,
    AVG(cl.claim_amount) AS avg_claim
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY c.smoker;
```

## Project Structure
```
insurance-sql-project/
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
│   └── data_processing.py
├── sql/
│   └── analysis.sql
├── README.md
├── requirements.txt
├── .gitignore
```

## Running the Project
1. Clone the repository  
2. Create a virtual environment  
3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
4. Run the data processing script:
   ```
   python data_processing.py
   ```
5. Load the data into Azure SQL using `bcp`  
6. Execute queries from `sql/analysis.sql`  

---

## Notes
Some elements of the dataset (such as premiums and claim records) are simulated to support analysis. This is intended to approximate how an insurance dataset might be structured rather than represent real-world data.

---

## Author
Jack Bennion