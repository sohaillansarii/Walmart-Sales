# Walmart Data Analysis: End-to-End SQL + Python Project 

## Project Overview

![Project Pipeline](walmart_project-pipelines.png)


This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. We utilize Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. The project is ideal for data analysts looking to develop skills in data manipulation, SQL querying, and data pipeline creation.


## Requirements

- **Python **
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** 


## Project Workflow

1. Data Loading & Exploration (Jupyter Notebook)
2. Data Cleaning using Pandas
3. Data Transformation
4. Database Upload (PostgreSQL)
5. Business Problem Solving using SQL

---

## Data Cleaning & Preprocessing (Pandas)

Data cleaning was performed in a Jupyter Notebook (`project.ipynb` file attached in this repository).
Following is the brief of the project:

### 1. Load Data

```python
df = pd.read_csv("walmart_unclean_data.csv")
```

### 2. Explore Data

```python
df.shape
df.info()
```

Initial size: 10,051 rows, 11 columns
Missing values in unit_price and quantity

---

### 3. Clean Data

```python
df.drop_duplicates(inplace=True)
df.dropna(inplace=True)
```

Final size: 9,969 rows

---

### 4. Transform Data

```python
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
df['total'] = df['unit_price'] * df['quantity']
df.columns = df.columns.str.lower()
```

---

### 5. Export & Load to PostgreSQL

```python
df.to_csv('walmart_clean_data.csv', index=False)

from sqlalchemy import create_engine
engine_psql = create_engine(
    "postgresql+psycopg2://postgres:password@localhost:5432/walmart_db"
)

df.to_sql('walmart', con=engine_psql, if_exists='append', index=False)
```


PostgreSQL connection was successfully established and data was inserted.

---

## SQL Analysis

### View Dataset

```sql
SELECT * FROM walmart;
```

---

### 1: Payment Methods Analysis

```sql
SELECT 
    payment_method,
    COUNT(*) AS transactions,
    SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY payment_method;
```

---

### 2: Highest-Rated Category per Branch

```sql
SELECT * 
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart 
    GROUP BY branch, category
) ranked
WHERE rank = 1;
```

---

### 3: Busiest Day per Branch

```sql
SELECT *
FROM (
    SELECT 
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, day_name
) ranked
WHERE rank = 1;
```

---

### 4: Quantity Sold per Payment Method

```sql
SELECT 
    payment_method,
    COUNT(*) AS transactions,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;
```

---

### 5: Rating Statistics by City & Category

```sql
SELECT
    city,
    category,
    AVG(rating) AS avg_rating,
    MAX(rating) AS max_rating,
    MIN(rating) AS min_rating
FROM walmart
GROUP BY city, category;
```

---

### 6: Profit by Category

```sql
SELECT
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category;
```

---

### 7: Most Common Payment Method per Branch

```sql
WITH ranked_payment_method AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT *
FROM ranked_payment_method
WHERE rank = 1;
```

---

### 8: Sales Shift Analysis

```sql
SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_invoices
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, total_invoices DESC;
```

---

### 9: Revenue Decrease Analysis (2022 vs 2023)

```sql
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD-MM-YY')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    ROUND((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric * 100, 2) AS decrease_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cs
    ON cs.branch = ls.branch
WHERE ls.revenue > cs.revenue
ORDER BY decrease_ratio DESC
LIMIT 5;
```

---

### 10: High-Sales Categories

```sql
SELECT 
    city,
    category,
    SUM(total) AS total_sales,
    SUM(quantity) AS quantity_sold,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category
HAVING SUM(total) > 10000
ORDER BY city, category;
```



---




##  Business Insights from SQL Analysis

- Evening time slots generated higher transaction volume compared to Morning and Afternoon shifts across most branches.
- E-wallet and Cash emerged as the most frequently used payment methods, showing strong customer preference for quick transactions.
- A few branches experienced a noticeable revenue decline between 2022 and 2023, highlighting underperforming locations.
- Health and Beauty / Electronics categories contributed heavily to overall revenue across multiple cities.
- Customer purchasing behavior varied by city, with distinct differences in preferred categories and payment methods.

## Author - SOHAIL ANSARI

