/*
===============================================================================
Project      : Enterprise Library Management System
File         : 02_schema_creation.sql
Author       : Ankit Shaw
Database     : PostgreSQL

Description:
Creates all core tables required for the Library Management System.

Execution Order:
2. Execute after creating the database.

===============================================================================
*/

-- ============================================================================
-- Table: branch
-- Stores information about each library branch.
-- ============================================================================

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(			branch_id VARCHAR(10) PRIMARY KEY,
			manager_id VARCHAR(10),
			branch_address VARCHAR(50),
			contact_no VARCHAR(15)
);

-- ============================================================================
-- Table: employees
-- Stores employee information and branch assignment.
-- ============================================================================

DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
			emp_id	VARCHAR(10) PRIMARY KEY,
			emp_name VARCHAR (25),	
			position VARCHAR (15),
			salary INT,
			branch_id VARCHAR(10) -- FK
);

-- ============================================================================
-- Table: books
-- Stores the complete catalog of books available in the library.
-- ============================================================================

DROP TABLE IF EXISTS books;
CREATE TABLE books
(
			isbn VARCHAR(20) PRIMARY KEY,
			book_title VARCHAR(60),
			category VARCHAR(20),
			rental_price FLOAT,
			status VARCHAR(5),
			author VARCHAR(25),
			publisher VARCHAR(30)
);

-- ============================================================================
-- Table: members
-- Stores information of the members of library
-- ============================================================================

DROP TABLE IF EXISTS members;
CREATE TABLE members
(
			member_id VARCHAR(10) PRIMARY KEY,
			member_name VARCHAR(25),
			member_address VARCHAR(50),
			reg_date DATE
);

-- ============================================================================
-- Table: issued_status
-- Stores information of the books issued to members
-- ============================================================================

DROP TABLE IF EXISTS issued_status
CREATE TABLE issued_status
(
			issued_id VARCHAR(10) PRIMARY KEY,
			issued_member_id VARCHAR(10), -- FK
			issued_book_name VARCHAR(60),
			issued_date	DATE,
			issued_book_isbn VARCHAR(20), -- FK
			issued_emp_id VARCHAR(10) --FK
);

-- ============================================================================
-- Table: returned_status
-- Stores information of the books returned by members
-- ============================================================================

DROP TABLE IF EXISTS returned_status;
CREATE TABLE returned_status
(
			return_id VARCHAR(10) PRIMARY KEY,
			issued_id VARCHAR(10), -- FK
			return_book_name VARCHAR(60),
			return_date	DATE,
			return_book_isbn VARCHAR(20) -- FK

);
