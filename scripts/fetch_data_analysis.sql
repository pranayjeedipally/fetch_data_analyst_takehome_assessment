
-- Fetch Data Analysis SQL Queries

-- Question 1: Top 5 brands by receipts scanned among users 21 and over
-- Assumption: Age is calculated as the difference between the current year and the user's birth year.
SELECT 
    p.brand, 
    COUNT(t.transaction_id) AS receipts_scanned
FROM 
    users u
JOIN 
    transactions t ON u.user_id = t.user_id
JOIN 
    products p ON t.product_id = p.product_id
WHERE 
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birth_date)) >= 21
GROUP BY 
    p.brand
ORDER BY 
    receipts_scanned DESC
LIMIT 5;

-- Question 2: Top 5 brands by sales among users that have had their account for at least six months
-- Assumption: Sales are calculated as transaction_quantity * product price.
SELECT 
    p.brand, 
    SUM(t.transaction_quantity * p.price) AS total_sales
FROM 
    users u
JOIN 
    transactions t ON u.user_id = t.user_id
JOIN 
    products p ON t.product_id = p.product_id
WHERE 
    CURRENT_DATE - u.account_creation_date >= INTERVAL '6 months'
GROUP BY 
    p.brand
ORDER BY 
    total_sales DESC
LIMIT 5;

-- Question 3: Percentage of sales in the Health & Wellness category by generation
-- Assumption: Generations are defined as follows:
-- Millennials: 1981-1996, Gen X: 1965-1980, Boomers: <1965, Gen Z: >1996.
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birth_date)) BETWEEN 1981 AND 1996 THEN 'Millennials'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birth_date)) BETWEEN 1965 AND 1980 THEN 'Gen X'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.birth_date)) < 1965 THEN 'Boomers'
        ELSE 'Gen Z'
    END AS generation,
    SUM(t.transaction_quantity * p.price) * 100.0 / 
    (SELECT SUM(t2.transaction_quantity * p2.price)
     FROM transactions t2
     JOIN products p2 ON t2.product_id = p2.product_id
     WHERE p2.category = 'Health & Wellness') AS percentage_of_sales
FROM 
    users u
JOIN 
    transactions t ON u.user_id = t.user_id
JOIN 
    products p ON t.product_id = p.product_id
WHERE 
    p.category = 'Health & Wellness'
GROUP BY 
    generation;

-- Question 4: Who are Fetch’s power users?
-- Assumption: Power users are the top 10% contributors based on total sales.
WITH user_sales AS (
    SELECT 
        u.user_id, 
        SUM(t.transaction_quantity * p.price) AS total_sales
    FROM 
        users u
    JOIN 
        transactions t ON u.user_id = t.user_id
    JOIN 
        products p ON t.product_id = p.product_id
    GROUP BY 
        u.user_id
),
sales_threshold AS (
    SELECT 
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_sales) AS sales_cutoff
    FROM 
        user_sales
)
SELECT 
    u.user_id, 
    u.name, 
    us.total_sales
FROM 
    user_sales us
JOIN 
    sales_threshold st ON us.total_sales >= st.sales_cutoff
JOIN 
    users u ON u.user_id = us.user_id;

-- Question 5: Leading brand in the Dips & Salsa category
-- Assumption: Leading brand is determined by the highest total sales.
SELECT 
    p.brand, 
    SUM(t.transaction_quantity * p.price) AS total_sales
FROM 
    products p
JOIN 
    transactions t ON p.product_id = t.product_id
WHERE 
    p.category = 'Dips & Salsa'
GROUP BY 
    p.brand
ORDER BY 
    total_sales DESC
LIMIT 1;

-- Question 6: Year-over-year growth percentage of Fetch
-- Assumption: Growth is based on the total number of transactions year over year.
WITH yearly_totals AS (
    SELECT 
        EXTRACT(YEAR FROM t.transaction_date) AS year, 
        COUNT(t.transaction_id) AS total_transactions
    FROM 
        transactions t
    GROUP BY 
        EXTRACT(YEAR FROM t.transaction_date)
)
SELECT 
    yt1.year AS year,
    (yt1.total_transactions - yt2.total_transactions) * 100.0 / yt2.total_transactions AS growth_percentage
FROM 
    yearly_totals yt1
JOIN 
    yearly_totals yt2 ON yt1.year = yt2.year + 1;
