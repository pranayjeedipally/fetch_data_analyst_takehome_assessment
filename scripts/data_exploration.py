import pandas as pd

# Load datasets
users = pd.read_csv("./data/USER_TAKEHOME.csv")
transactions = pd.read_csv("./data/TRANSACTION_TAKEHOME.csv")
products = pd.read_csv("./data/PRODUCTS_TAKEHOME.csv")

# Inspect datasets
print("Users Dataset:")
print(users.head())
print(users.info())

print("\nTransactions Dataset:")
print(transactions.head())
print(transactions.info())

print("\nProducts Dataset:")
print(products.head())
print(products.info())

# Check for missing values
print("\nMissing Values:")
print("Users:", users.isnull().sum())
print("Transactions:", transactions.isnull().sum())
print("Products:", products.isnull().sum())
