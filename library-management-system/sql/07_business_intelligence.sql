/*
===============================================================================
Project      : Enterprise Library Management System
File         : 07_business_intelligence.sql

Description:
Analytical SQL queries designed to support business intelligence, operational
performance monitoring, and management reporting.

===============================================================================
*/

-- ============================================================================
-- Use Case 10
--  Members who have overdue books (assumed a 30-day return period).
-- ============================================================================
SELECT 
	m.member_id, 
	m.member_name,
	i.issued_book_name,
	i.issued_date,
	-- r.return_date,
	CURRENT_DATE - i.issued_date AS over_dues_date
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
LEFT JOIN returned_status r
ON i.issued_id = r.issued_id
WHERE return_date IS NULL
AND CURRENT_DATE - i.issued_date > 30
ORDER BY over_dues_date DESC;

-- ============================================================================
-- Use Case 11
/* 
Performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
-- ============================================================================
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
returned_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id;

-- ============================================================================
-- Use Case 12
-- Top 3 Employees with the Most Book Issues Processed.
-- ============================================================================
SELECT 
	e.emp_name, 
	b.branch_id,
	COUNT(i.issued_id) AS books_processed_count
FROM employees e
JOIN issued_status i
ON e.emp_id = i.issued_emp_id
JOIN branch b
ON b.branch_id = e.branch_id
GROUP BY
	e.emp_name, 
	b.branch_id
ORDER BY books_processed_count DESC
LIMIT 3;

-- ============================================================================
-- Use Case 13
-- Members who have issued books more than twice with the status "damaged" in the books table.
-- ============================================================================
SELECT 
	m.member_name, 
	i.issued_book_name,
	COUNT(r.book_quality) AS damaged_count
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
JOIN returned_status r
ON i.issued_id = r.issued_id
WHERE r.book_quality = 'Damaged'
GROUP BY 
	m.member_name,
	i.issued_book_name
HAVING COUNT(r.book_quality) > 2;
