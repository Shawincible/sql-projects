/*
================================================================================
Project     : Zomato Data Analysis
File        : 02_schema_creation.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Creates the five core tables for the Zomato Data Analysis project:
customers, restaurants, orders, riders, and deliveries.

Execution Order:
2. Execute after 01_database_setup.sql, connected to zomato_db.
================================================================================
*/

-- ================================================================================
-- Table: customers
-- ================================================================================

CREATE TABLE customers
(
	customer_id INT	PRIMARY KEY NOT NULL,
	customer_name VARCHAR (15),
	reg_date DATE
);

-- ================================================================================
-- Table: restaurants
-- ================================================================================

CREATE TABLE restaurants
(
	restaurant_id INT PRIMARY KEY NOT NULL,
	restaurant_name VARCHAR (25),
	city VARCHAR (15),
	opening_hours VARCHAR (25)
);

-- ================================================================================
-- Table: orders
-- ================================================================================

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

-- ================================================================================
-- Table: riders
-- ================================================================================

CREATE TABLE riders
(
	rider_id INT PRIMARY KEY NOT NULL,
	rider_name VARCHAR (15),
	sign_up DATE
);

-- ================================================================================
-- Table: deliveries
-- ================================================================================

CREATE TABLE deliveries
(
	delivery_id INT PRIMARY KEY NOT NULL,
	order_id INT,
	delivery_status VARCHAR (15),
	delivery_time TIME,
	rider_id INT
);
