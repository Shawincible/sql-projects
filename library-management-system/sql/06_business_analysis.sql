/*
===============================================================================
Project      : Enterprise Library Management System
File         : 06_operational_analysis.sql

Description:
Operational SQL queries supporting daily library operations and monitoring.

===============================================================================
*/

-- ============================================================================
-- Use Case 4
-- All Books Issued by a Specific Employee.
-- ============================================================================
SELECT issued_book_name 
FROM issued_status
WHERE issued_emp_id = 'E101';

-- ============================================================================
-- Use Case 5
-- Members issuing more than one book.
-- ============================================================================
SELECT 
	issued_emp_id,
	COUNT(issued_id) AS number_of_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;

-- ============================================================================
-- Use Case 6
-- All Books in a Specific Category.
-- ============================================================================
SELECT * FROM books
WHERE category = 'Fantasy';

-- ============================================================================
-- Use Case 7
-- Total Rental Income by Category.
-- ============================================================================
SELECT 
	category, 
	SUM(rental_price) AS total_rents,
	COUNT(*) AS issued
FROM books
GROUP BY category;

-- ============================================================================
-- Use Case 7
-- Members Who Registered in the Last 180 Days.
-- ============================================================================
SELECT 
  member_id, 
  member_name 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- ============================================================================
-- Use Case 8
-- Employees with Their Branch Manager's Name and their branch details.
-- ============================================================================
SELECT 
	e.emp_id,
	e.emp_name,
	m.emp_name AS manager_name,
	b.*
FROM employees e
JOIN branch b
ON e.branch_id = b.branch_id
JOIN employees m
ON m.emp_id = b.manager_id;

-- ============================================================================
-- Use Case 9
-- List of Books Not Yet Returned.
-- ============================================================================
SELECT *
FROM issued_status i
LEFT JOIN returned_status r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
