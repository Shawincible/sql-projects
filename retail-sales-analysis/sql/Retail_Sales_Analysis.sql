-- SQL Retail Sales Analysis
CREATE DATABASE retail_sales_db;

-- CREATE TABLE
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

-- Data Cleaning
-- Check Null Values

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

-- Deleting rows

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

SELECT COUNT(*) AS Number_of_rows FROM retail_sales;

-- Data Exploration

-- How many Sales we have?
SELECT COUNT(*) FROM retail_sales;

-- How many unique Customers we have?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- How many unique Categories we have?
SELECT DISTINCT category FROM retail_sales;

-- Data Analysis & Business Key Problems
-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
-- 2. Write a SQL query to retrieve all transactions where the Category is 'Clothing' and the quantity sold is more than 3 in the month of Nov 2022
-- 3. Write a SQL query to calculate the total sales for each category
-- 4. Write a SQL query to find the average age of customers who purchased items from the Beauty category
-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000
-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
-- 8. Write a SQL query to find the top 5 customers based on the highest total_sales
-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.
-- 10. Write a SQL query to create each shift and number of orders. (Example Morning <= 12, Afternoon Between 12 & 17, Evening > 17)

SELECT * FROM retail_sales
LIMIT 5;
-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the Category is 'Clothing' and the quantity sold is more than 3 in the month of Nov 2022
SELECT * 
FROM retail_sales
WHERE 
	category = 'Clothing' 
AND 
	quantity > 3
AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- 3. Write a SQL query to calculate the total sales for each category
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- 4. Write a SQL query to find the average age of customers who purchased items from the Beauty category
SELECT ROUND(AVG(age), 2) AS average_age_for_beauty
FROM retail_sales
WHERE category = 'Beauty';

-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.

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

-- 8. Write a SQL query to find the top 5 customers based on the highest total_sales
SELECT customer_id, SUM(total_sale) AS highest_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
	category,
	COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;

-- 10. Write a SQL query to create each shift and number of orders. (Example Morning <= 12, Afternoon Between 12 & 17, Evening > 17)
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