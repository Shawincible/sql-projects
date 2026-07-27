-- Zomato Data Analysis

-- Database Creation of 
CREATE DATABASE zomato_db;

-- Table Creation

CREATE TABLE customers
(
	customer_id INT	PRIMARY KEY NOT NULL,
	customer_name VARCHAR (15),
	reg_date DATE
);

CREATE TABLE restaurants
(
	restaurant_id INT PRIMARY KEY NOT NULL,
	restaurant_name VARCHAR (25),
	city VARCHAR (15),
	opening_hours VARCHAR (25)
);

CREATE TABLE orders
(
	order_id INT PRIMARY KEY NOT NULL,
	customer_id INT,
	restaurant_id INT,
	order_item VARCHAR (25),
	order_date DATE,
	order_time TIME,
	order_status VARCHAR (15),
	total_amount FLOAT
);

CREATE TABLE riders
(
	rider_id INT PRIMARY KEY NOT NULL,
	rider_name VARCHAR (15),
	sign_up DATE
);

CREATE TABLE deliveries
(
	delivery_id INT PRIMARY KEY NOT NULL,
	order_id INT,
	delivery_status VARCHAR (15),
	delivery_time TIME,
	rider_id INT
);

-- Adding FK Constraints

ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders
ADD CONSTRAINT fk_restaurants
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_riders
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);

-- Business Case

-- 1. Write a query to find the top 5 most frequently ordered dishes by customer_id is 7 in last 2 years.

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

-- 2. Identify the time slots during which the most orders are placed based on 2 hour intervals.

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

-- 3. Find the average order value per customer who has placed more than 20 orders.

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

-- 4. List the customers who have spent more than 18k in total on food orders.

SELECT 
	c.customer_id,
	ROUND(SUM(o.total_amount)::NUMERIC,2) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING ROUND(SUM(o.total_amount)::NUMERIC,2) > 18000
ORDER BY total_spent DESC;

-- 5. Find orders that were placed but not delivered. Return restaurant name, city and number of not delivered orders.

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

-- 6. Rank restaurants by their total revenue from last 2 years, including their name, total revenue, and rank within their city.
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

-- 7. Identify the most popular dish in each city based on the number of orders.
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

-- 8. Customers who haven't placed an order in 2025 but did in 2024.

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

/*
 9. Calculate and compare the order cancellation rate for each restaurant 
	between the current year and the previous year
*/

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

-- 10. Determine each rider's average delivery time.

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
GROUP BY d.rider_id

-- 11. Calculate month-wise growth ratio of each restaurant based on the total number of delivered orders.

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

/*
12. Segment Customers into Gold and Silver groups based on their total spending compared to the avg order value.
	If the customer's total spending exceeds the avg order value, label them as Gold, otherwise label them as Silver.
	Determine each segment's total number of orders and total revenue.
*/

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

-- 13. Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

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
	month

/*
14. Find the number of 5-star, 4-star and 3-star ratings each rider has.
	Riders receive this rating based on delivery time.
	If orders are delivered less than 15 minutes of orders received, the rider gets 5 star rating.
	If they deliver between 15 and 20 minutes, they get 4 star rating.
	If they deliver after 20 minutes, they get 3 star rating.
*/

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

-- 15. Analyze Order Frequency per day of the week and identify the peak day for each restaurant.

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

-- 16. Calculate the total revenue generated by each customer over all their orders.

SELECT 
	customer_id,
	ROUND(SUM(total_amount)::NUMERIC, 2) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY total_revenue DESC;

SELECT 
total_amount
FROM orders;

-- 17. Identify sales trends by comparing each month's total sales to the previous month's

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
FROM sales_trends

-- 18. Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.

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

-- 19. Track the popularity of specific order items over time and identify seasonal demand spikes

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

-- 20. Rank each city based on the total revenue for last year 2024

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