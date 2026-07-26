/*
===============================================================================
Project      : Enterprise Library Management System
File         : 05_crud_operations.sql
Author       : Ankit Shaw
Database     : PostgreSQL

Description:
Demonstrates CRUD (Create, Read, Update, Delete) operations performed on the
Library Management System.

Execution Order:
Execute after populating the database.

===============================================================================
*/

-- ============================================================================
-- Use Case 1
-- Add a new book to the library inventory.
-- ============================================================================
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- ============================================================================
-- Use Case 2
-- Update an existing member's address.
-- ============================================================================
UPDATE members
SET member_address = '256 Bidhan Nagar Road'
WHERE member_id = 'C105';

-- ============================================================================
-- Use Case 3
-- Delete a Record from the Issued Status Table.
-- ============================================================================
DELETE FROM issued_status
WHERE issued_id = 'IS121';
