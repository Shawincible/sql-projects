/*
================================================================================
Project     : Retail Sales Analysis
File        : 04_data_exploration.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Performs initial exploration of the cleaned dataset — total sales volume,
unique customers, and unique product categories.

Execution Order:
4. Execute after 03_data_cleaning.sql.
================================================================================
*/

-- ================================================================================
-- How many Sales do we have?
-- ================================================================================

SELECT COUNT(*) FROM retail_sales;

-- ================================================================================
-- How many unique Customers do we have?
-- ================================================================================

SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- ================================================================================
-- How many unique Categories do we have?
-- ================================================================================

SELECT DISTINCT category FROM retail_sales;

-- ================================================================================
-- Preview Sample Data
-- ================================================================================

SELECT * FROM retail_sales
LIMIT 5;
