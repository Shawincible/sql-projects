/*
================================================================================
Project     : Retail Sales Analysis
File        : 02_schema_creation.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Creates the retail_sales table and corrects a column naming issue.

Execution Order:
2. Execute after 01_database_setup.sql, connected to retail_sales_db.
================================================================================
*/

-- ================================================================================
-- Create Table
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

-- ================================================================================
-- Fix Column Naming
-- ================================================================================

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;
