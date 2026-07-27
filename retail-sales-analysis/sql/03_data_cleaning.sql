/*
================================================================================
Project     : Retail Sales Analysis
File        : 03_data_cleaning.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Identifies and removes records with NULL values across key columns to
ensure clean, reliable data for analysis.

Execution Order:
3. Execute after loading data into retail_sales.
================================================================================
*/

-- ================================================================================
-- Check Null Values
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

-- ================================================================================
-- Delete Rows with Null Values
-- ================================================================================

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

-- ================================================================================
-- Verify Row Count After Cleaning
-- ================================================================================

SELECT COUNT(*) AS number_of_rows FROM retail_sales;
