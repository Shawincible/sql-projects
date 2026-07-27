/*
================================================================================
Project     : Retail Sales Analysis
File        : retail_sales_analysis.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Full combined script for the Retail Sales Analysis project — includes
database setup, schema creation, data cleaning, data exploration, and
business analysis queries in a single file.

Execution Order:
Run this file top-to-bottom for the complete project, or run the
numbered scripts (01-05) individually in order.
================================================================================
*/

-- ================================================================================
-- 01: Database Setup
-- ================================================================================

CREATE DATABASE retail_sales_db;

-- ================================================================================
-- 02: Schema Creation
-- ================================================================================

CREATE TABLE retail_sales 
			(
				transactions_id	INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id	INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

-- ================================================================================
-- 03: Data Cleaning
-- ================================================================================

SELECT * FROM retail_sales
WHERE 
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
category IS NULL
OR
quantity IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
transactions_id IS NULL
OR
sale_date IS NULL
OR
sale_time IS NULL
OR
customer_id IS NULL
OR
gender IS NULL
OR
category IS NULL
OR
quantity IS NULL
OR
price_per_unit IS NULL
OR
cogs IS NULL
OR
total_sale IS NULL;

SELECT COUNT(*) AS number_of_rows FROM retail_sales;

-- ================================================================================
-- 04: Data Exploration
-- ================================================================================

SELECT COUNT(*) FROM retail_sales;

SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
LIMIT 5;

-- ================================================================================
-- 05: Business Analysis
-- ================================================================================

-- Use Case 1: Retrieve all columns for sales made on '2022-11-05'
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Use Case 2: Clothing category, quantity > 3, Nov 2022
SELECT * 
FROM retail_sales
WHERE 
	category = 'Clothing' 
AND 
	quantity > 3
AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Use Case 3: Total sales for each category
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- Use Case 4: Average age of customers in Beauty category
SELECT ROUND(AVG(age), 2) AS average_age_for_beauty
FROM retail_sales
WHERE category = 'Beauty';

-- Use Case 5: Transactions where total_sale > 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Use Case 6: Transactions by gender and category
SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Use Case 7: Best selling month per year
SELECT 
	year, month, avg_sales 
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT (MONTH FROM sale_date) AS month,
		(AVG(total_sale)) AS avg_sales,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY (AVG(total_sale)) ) AS rank
	FROM retail_sales
	GROUP BY 
		EXTRACT(YEAR FROM sale_date), EXTRACT (MONTH FROM sale_date)
) AS t1
WHERE rank = 1;

-- Use Case 8: Top 5 customers by total sales
SELECT customer_id, SUM(total_sale) AS highest_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- Use Case 9: Unique customers per category
SELECT 
	category,
	COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;

-- Use Case 10: Orders by shift
WITH hourly_sales AS
(
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) <=12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT 
	shift, 
	COUNT(*) AS orders
FROM hourly_sales
GROUP BY shift;

-- End of Project
