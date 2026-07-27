/*
================================================================================
Project     : Zomato Data Analysis
File        : 04_business_analysis.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Core business analysis queries (Use Cases 1-10) covering customer ordering
behavior, peak time slots, spending patterns, delivery performance, and
restaurant revenue ranking.

Execution Order:
4. Execute after 03_constraints_and_relationships.sql and after data has
   been loaded into all tables.
================================================================================
*/

-- ================================================================================
-- Use Case 1
-- Find the top 5 most frequently ordered dishes by customer_id 7 in the
-- last 2 years.
-- ================================================================================

SELECT
	customer_id,
	dishes,
	no_of_orders
FROM
	(SELECT
		c.customer_id,
		o.order_item AS dishes,
		COUNT (o.order_item) AS no_of_orders,
		DENSE_RANK() OVER(ORDER BY COUNT (o.order_item) DESC) AS order_rank
	FROM orders o
	JOIN customers c
	ON o.customer_id = c.customer_id
	WHERE 
		c.customer_id = 7
	AND
		o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
	GROUP BY 
		c.customer_id,
		o.order_item) AS t1
WHERE order_rank <= 5;

-- ================================================================================
-- Use Case 2
-- Identify the time slots during which the most orders are placed based
-- on 2-hour intervals.
-- ================================================================================

SELECT 
	COUNT(*) total_orders,
	CASE
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
	END AS time_slot
FROM orders
GROUP BY time_slot
ORDER BY total_orders DESC;

-- ================================================================================
-- Use Case 3
-- Find the average order value per customer who has placed more than
-- 20 orders.
-- ================================================================================

SELECT 
	c.customer_id,
	COUNT(o.*) AS order_count,
	ROUND(AVG(o.total_amount)::NUMERIC, 2) AS avg_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.*) > 20
ORDER BY avg_order_value DESC;

-- ================================================================================
-- Use Case 4
-- List the customers who have spent more than 18k in total on food orders.
-- ================================================================================

SELECT 
	c.customer_id,
	ROUND(SUM(o.total_amount)::NUMERIC,2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING ROUND(SUM(o.total_amount)::NUMERIC,2) > 18000
ORDER BY total_spent DESC;

-- ================================================================================
-- Use Case 5
-- Find orders that were placed but not delivered. Return restaurant name,
-- city, and number of not-delivered orders.
-- ================================================================================

SELECT 
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS not_delivered_orders
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
LEFT JOIN deliveries d
    ON o.order_id = d.order_id
WHERE d.delivery_status <> 'Delivered'
GROUP BY 
    r.restaurant_name,
    r.city
ORDER BY 
    not_delivered_orders DESC;

-- ================================================================================
-- Use Case 6
-- Rank restaurants by their total revenue from the last 2 years, including
-- their name, total revenue, and rank within their city.
-- ================================================================================

SELECT 
	r.restaurant_name,
	r.city,
	ROUND(SUM(o.total_amount)::NUMERIC, 2) AS total_revenue,
	RANK() OVER(PARTITION BY r.city ORDER BY ROUND(SUM(o.total_amount)::NUMERIC, 2) DESC) AS revenue_rank
FROM restaurants r
JOIN orders o
ON r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
GROUP BY 
	r.city,
	r.restaurant_name;

-- ================================================================================
-- Use Case 7
-- Identify the most popular dish in each city based on the number of orders.
-- ================================================================================

WITH popular_dish AS
( 
	SELECT
		r.city,
		o.order_item,
		COUNT(o.*) AS number_of_times_ordered,
		RANK() OVER(PARTITION BY r.city ORDER BY COUNT(o.*) DESC) order_rank
	FROM orders o
	JOIN restaurants r
	ON o.restaurant_id = r.restaurant_id
	GROUP BY 
		r.city,
		o.order_item
)

SELECT * FROM popular_dish
WHERE order_rank = 1;

-- ================================================================================
-- Use Case 8
-- Customers who haven't placed an order in 2025 but did in 2024.
-- ================================================================================

SELECT
	DISTINCT customer_id
FROM orders
WHERE 
	EXTRACT (YEAR FROM order_date) = 2024
	AND 
	customer_id NOT IN 
					(SELECT DISTINCT customer_id
					FROM orders
					WHERE EXTRACT (YEAR FROM order_date) = 2025);

-- ================================================================================
-- Use Case 9
-- Calculate and compare the order cancellation rate for each restaurant
-- between the current year and the previous year.
-- ================================================================================

WITH order_cancellation_rate AS
(	
	SELECT 
	EXTRACT(YEAR FROM order_date) AS year,
	restaurant_id,
	COUNT(*) AS total_orders,
	COUNT(
		CASE
			WHEN order_status = 'Cancelled' THEN 1
			END
		) AS cancelled_orders,
	ROUND(COUNT(
		CASE
			WHEN order_status = 'Cancelled' THEN 1
			END
		):: NUMERIC/COUNT(*) *100, 2) AS cancellation_rate
	FROM orders
	GROUP BY 
		restaurant_id, 
		EXTRACT(YEAR FROM order_date)
)
SELECT 
	restaurant_id,
	MAX(CASE
			WHEN year = 2024 
			THEN cancellation_rate
		END) AS previous_cancellation_year_rate,
		
	MAX(CASE
			WHEN year = 2025 
			THEN cancellation_rate
		END) AS current_year_cancellation_rate
		
FROM order_cancellation_rate
GROUP BY restaurant_id;

-- ================================================================================
-- Use Case 10
-- Determine each rider's average delivery time.
-- ================================================================================

SELECT
	d.rider_id,
	ROUND(AVG(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
	CASE 
		WHEN d.delivery_time < o.order_time
		THEN INTERVAL '1 day'
		ELSE INTERVAL '0 day'
	END))/60)) AS delivery_time
FROM orders o
JOIN deliveries d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY d.rider_id;
