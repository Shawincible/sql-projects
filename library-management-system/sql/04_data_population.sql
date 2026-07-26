/*
===============================================================================
Project      : Enterprise Library Management System
File         : 04_data_population.sql
Author       : Ankit Shaw
Database     : PostgreSQL

Description:
Populates the database with sample data required for testing and analysis.

Execution Order:
4. Execute after creating tables and relationships.

===============================================================================
*/

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
