 
import pandas as pd
import numpy as np

# load data

def load_data(file_path):
    """
    Load the dataset from a CSV file and perform initial inspection.
    """
    # Read CSV into DataFrame
    df = pd.read_csv(file_path)

    # Preview first 5 rows
    print("First 5 rows of dataset:")
    print(df.head())

    # Show structure and data types
    print("\nDataset info:")
    print(df.info())

    # Show summary statistics
    print("\nSummary statistics:")
    print(df.describe())

    return df

# clean data

def clean_data(df):
    """
    Clean and standardise the dataset
    """
    # Standardise column names
    df.columns = df.columns.str.lower().str.strip()

    # Convert categorical values
    df['sex'] = df['sex'].map({0: 'female', 1: 'male'})
    df['smoker'] = df['smoker'].map({0: 'no', 1: 'yes'})

    region_map = {
        0: 'northeast',
        1: 'northwest',
        2: 'southeast',
        3: 'southwest'
    }
    df['region'] = df['region'].map(region_map)

    # Check for missing values and mapping
    print('\nMissing values per column:')
    print(df.isnull().sum())

    assert set(df['sex'].unique()) <= {'male', 'female'}
    assert set(df['smoker'].unique()) <= {'yes', 'no'}
    assert set(df['region'].unique()) <= {'northeast', 'northwest', 'southeast', 'southwest'}

    return df

# Create relational tables

def create_customers(df):
    df['customer_id'] = range(1, len(df) + 1)
    customers = df[['customer_id', 'age', 'sex', 'bmi', 'children', 'smoker', 'region']]
    return customers

def create_policies(df):
    # simulate premium based on risk
    df['premium_amount'] = (
        df['charges'] * 0.7 +
        df['bmi'] * 50 +
        df['children'] * 200 + 
        np.where(df['smoker'] == 'yes', 5000, 0)
    )

    df['policy_id'] = range(1, len(df) + 1)

    policies = df[['policy_id', 'customer_id', 'premium_amount']]
    return policies

def create_claims(df):
    claims_list = []
    claim_id = 1

    for _, row in df.iterrows():
        num_claims = np.random.randint(0,4)

        for _ in range(num_claims):
            claim_amount = abs(np.random.normal(
                loc=row['charges'],
                scale=row['charges'] * 0.3
            ))

            claims_list.append({
                'claim_id': claim_id,
                'policy_id': row['policy_id'],
                'claim_amount': round(claim_amount, 2),
                'claim_status': 'Approved' if np.random.rand() > 0.2 else 'Rejected'
            })

            claim_id += 1

    claims = pd.DataFrame(claims_list)
    return claims

def export_data(customers, policies, claims):
    """
    Export cleaned tables to CSV for loading to Azure SQL
    """
    customers.to_csv("customers.csv", index=False)
    policies.to_csv("policies.csv", index=False)
    claims.to_csv("claims.csv", index=False)

    print("\nData exported successfully")

def main():
    file_path = "/Users/jackbennion/Documents/Data Analysis Projects/Insurance Claims/insurance3r2.csv"
    df = load_data(file_path)
    df = clean_data(df)

    customers = create_customers(df)
    policies = create_policies(df)
    claims = create_claims(df)

    print("\nCustomers preview:")
    print(customers.head())

    print("\nPolicies preview:")
    print(policies.head())

    print("\nClaims preview:")
    print(claims.head())

    # sanity checks

    assert customers['customer_id'].is_unique
    assert customers.isnull().sum().sum() == 0

    assert policies['policy_id'].is_unique
    assert policies['customer_id'].is_unique

    assert (policies['premium_amount'] > 0).all()

    assert set(claims['policy_id']).issubset(set(policies['policy_id']))

    assert (claims['claim_amount'] >= 0).all()

    export_data(customers,policies, claims)

if __name__ == "__main__":
    main()
