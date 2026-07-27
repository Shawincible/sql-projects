/*
================================================================================
Project     : Zomato Data Analysis
File        : 05_business_intelligence.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Advanced business intelligence queries (Use Cases 11-20) covering growth
rates, customer segmentation, rider earnings and ratings, seasonal demand,
and city-level revenue ranking.

Execution Order:
5. Execute after 04_business_analysis.sql.
================================================================================
*/

-- ================================================================================
-- Use Case 11
-- Calculate month-wise growth ratio of each restaurant based on the total
-- number of delivered orders.
-- ================================================================================

WITH restaurant_growth_rate AS
(
	SELECT 
		restaurant_id,
		DATE_TRUNC('month', order_date) AS month,
		COUNT(*) AS current_month_orders,
		LAG(COUNT(*), 1) OVER(PARTITION BY restaurant_id ORDER BY DATE_TRUNC('month', order_date)) as previous_month_orders
	FROM orders 
	WHERE order_status = 'Delivered'
	GROUP BY 
		restaurant_id,
		DATE_TRUNC('month', order_date)
)
SELECT 
	restaurant_id,
	TO_CHAR (month, 'mm-yy') AS month,
	previous_month_orders,
	current_month_orders,
	ROUND((current_month_orders - previous_month_orders)::NUMERIC/NULLIF(previous_month_orders, 0)*100,2) AS growth_rate
FROM restaurant_growth_rate;

-- ================================================================================
-- Use Case 12
-- Segment customers into Gold and Silver groups based on their total
-- spending compared to the average order value. If a customer's total
-- spending exceeds the average order value, label them Gold, otherwise
-- Silver. Determine each segment's total number of orders and total revenue.
-- ================================================================================

WITH customer_segmentation AS
(
	SELECT 
		customer_id,
		ROUND(SUM(total_amount)::NUMERIC,2) AS total_spent,
		COUNT(*) AS total_orders,
		CASE
			WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold'
			ELSE 'Silver'
		END AS customer_label
	FROM orders
	GROUP BY customer_id
)
SELECT 
	customer_label,
	SUM(total_orders) AS total_orders,
	SUM(total_spent) AS total_revenue
FROM customer_segmentation
GROUP BY 
	customer_label;

-- ================================================================================
-- Use Case 13
-- Calculate each rider's total monthly earnings, assuming they earn 8%
-- of the order amount.
-- ================================================================================

SELECT 
	d.rider_id,
	TO_CHAR(o.order_date, 'mm-yy') AS month,
	ROUND(SUM(o.total_amount)::NUMERIC * 0.08,2) AS riders_earnings
FROM orders o
JOIN deliveries d
ON o.order_id = d.order_id
GROUP BY 
	d.rider_id,
	TO_CHAR(o.order_date, 'mm-yy')
ORDER BY
	d.rider_id,
	month;

-- ================================================================================
-- Use Case 14
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- Riders receive a rating based on delivery time: under 15 minutes = 5-star,
-- 15-20 minutes = 4-star, over 20 minutes = 3-star.
-- ================================================================================

WITH rider_rating AS
(
    SELECT
        d.rider_id,
        ROUND(
            EXTRACT(
                EPOCH FROM
                (
                    d.delivery_time - o.order_time +
                    CASE
                        WHEN d.delivery_time < o.order_time
                        THEN INTERVAL '1 day'
                        ELSE INTERVAL '0 day'
                    END
                )
            ) / 60,
            2
        ) AS delivery_minutes
    FROM deliveries d
    JOIN orders o
        ON d.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
),

rating_count AS
(
    SELECT
        *,
        CASE
            WHEN delivery_minutes < 15 THEN '5-star'
            WHEN delivery_minutes BETWEEN 15 AND 20 THEN '4-star'
            ELSE '3-star'
        END AS rating
    FROM rider_rating
)

SELECT
    rider_id,
    rating,
    COUNT(*) AS star_rating_count
FROM rating_count
GROUP BY
    rider_id,
    rating
ORDER BY
	rider_id;

-- ================================================================================
-- Use Case 15
-- Analyze order frequency per day of the week and identify the peak day
-- for each restaurant.
-- ================================================================================

SELECT * FROM 
(
	SELECT 
		restaurant_id,
		TO_CHAR(order_date, 'Day') AS day,
		COUNT(*) AS orders,
		RANK() OVER (PARTITION BY(restaurant_id) ORDER BY COUNT(*) DESC) AS order_rank
	FROM orders
	GROUP BY 
		restaurant_id,
		TO_CHAR(order_date, 'Day')
) AS t1
WHERE order_rank =1;

-- ================================================================================
-- Use Case 16
-- Calculate the total revenue generated by each customer over all their
-- orders.
-- ================================================================================

SELECT 
	customer_id,
	ROUND(SUM(total_amount)::NUMERIC, 2) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- ================================================================================
-- Use Case 17
-- Identify sales trends by comparing each month's total sales to the
-- previous month's.
-- ================================================================================

WITH sales_trends AS
(
	SELECT
		ROUND(SUM(total_amount)::NUMERIC,2) AS current_month_sales,
		EXTRACT(YEAR FROM order_date) AS year,
		EXTRACT(MONTH FROM order_date) AS month,
		LAG(ROUND(SUM(total_amount)::NUMERIC,2), 1) OVER(ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) AS previous_month_sales
	FROM orders
	GROUP BY
		EXTRACT(YEAR FROM order_date),
		EXTRACT(MONTH FROM order_date)
)
SELECT
	year,
	month,
	previous_month_sales,
	current_month_sales,
	ROUND((current_month_sales - previous_month_sales)/previous_month_sales*100::NUMERIC,2) AS trend
FROM sales_trends;

-- ================================================================================
-- Use Case 18
-- Evaluate rider efficiency by determining average delivery times and
-- identifying those with the lowest and highest averages.
-- ================================================================================

WITH delivery_efficiency AS
(
	SELECT
		d.rider_id,
		ROUND(EXTRACT(EPOCH FROM 
			(d.delivery_time - o.order_time +
			CASE 
				WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
				ELSE INTERVAL '0 day'
			END))/60,2) AS delivery_minutes
	FROM
		orders AS o
	JOIN
		deliveries AS d
	ON o.order_id = d.order_id
	WHERE delivery_status = 'Delivered'
),
rider_efficiency AS
(
	SELECT
		rider_id,
		AVG(delivery_minutes) AS avg_delivery_time
	FROM delivery_efficiency
	GROUP BY rider_id
)

SELECT
	ROUND(MIN(avg_delivery_time)::NUMERIC,2) AS minimum_delivery_time,
	ROUND(MAX(avg_delivery_time)::NUMERIC,2) AS maximum_delivery_time
FROM rider_efficiency;

-- ================================================================================
-- Use Case 19
-- Track the popularity of specific order items over time and identify
-- seasonal demand spikes.
-- ================================================================================

SELECT 
	order_item,
	seasons,
	COUNT(*) AS total_orders
FROM
(
SELECT
	order_item,
	EXTRACT(MONTH FROM order_date) AS month,
	CASE
		WHEN EXTRACT(MONTH FROM order_date) BETWEEN 2 AND 3 THEN 'Spring'
		WHEN EXTRACT(MONTH FROM order_date) BETWEEN 4 AND 6 THEN 'Summer'
		WHEN EXTRACT(MONTH FROM order_date) BETWEEN 7 AND 8 THEN 'Rainy'
		ELSE 'Winter'
	END AS seasons
FROM orders
) AS seasonal_demand
GROUP BY 
	order_item,
	seasons
ORDER BY 
	order_item,
	total_orders DESC;

-- ================================================================================
-- Use Case 20
-- Rank each city based on the total revenue for the last year (2024).
-- ================================================================================

SELECT
	city, 
	total_revenue,
	RANK() OVER(ORDER BY total_revenue DESC) AS city_rank
FROM
(
	SELECT 
		r.city,
		ROUND(SUM(o.total_amount)::NUMERIC,2) AS total_revenue
	FROM restaurants r
	JOIN orders o 
	ON r.restaurant_id = o.restaurant_id
	WHERE EXTRACT(YEAR FROM o.order_date) = '2024'
	GROUP BY 
		r.city
) AS city_per_revenue;

-- End of Project
