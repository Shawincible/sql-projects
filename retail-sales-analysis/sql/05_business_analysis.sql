/*
================================================================================
Project     : Retail Sales Analysis
File        : 05_business_analysis.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Answers 10 real-world retail business questions using the cleaned
retail_sales dataset — covering sales trends, customer behavior,
and category-level performance.

Execution Order:
5. Execute after 04_data_exploration.sql.
================================================================================
*/

-- ================================================================================
-- Use Case 1
-- Retrieve all columns for sales made on '2022-11-05'
-- ================================================================================

SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- ================================================================================
-- Use Case 2
-- Retrieve all transactions where the Category is 'Clothing' and the quantity 
-- sold is more than 3 in the month of Nov 2022
-- ================================================================================

SELECT * 
FROM retail_sales
WHERE 
	category = 'Clothing' 
AND 
	quantity > 3
AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- ================================================================================
-- Use Case 3
-- Calculate the total sales for each category
-- ================================================================================

SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- ================================================================================
-- Use Case 4
-- Find the average age of customers who purchased items from the Beauty category
-- ================================================================================

SELECT ROUND(AVG(age), 2) AS average_age_for_beauty
FROM retail_sales
WHERE category = 'Beauty';

-- ================================================================================
-- Use Case 5
-- Find all transactions where the total_sale is greater than 1000
-- ================================================================================

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- ================================================================================
-- Use Case 6
-- Find the total number of transactions (transaction_id) made by each gender 
-- in each category
-- ================================================================================

SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- ================================================================================
-- Use Case 7
-- Calculate the average sale for each month. Find out the best selling month 
-- in each year
-- ================================================================================

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

-- ================================================================================
-- Use Case 8
-- Find the top 5 customers based on the highest total_sales
-- ================================================================================

SELECT customer_id, SUM(total_sale) AS highest_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- ================================================================================
-- Use Case 9
-- Find the number of unique customers who purchased items from each category
-- ================================================================================

SELECT 
	category,
	COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;

-- ================================================================================
-- Use Case 10
-- Create each shift and number of orders 
-- (Example: Morning <= 12, Afternoon Between 12 & 17, Evening > 17)
-- ================================================================================

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
