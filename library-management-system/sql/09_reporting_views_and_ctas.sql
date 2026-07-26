/*
===============================================================================
Project      : Enterprise Library Management System
File         : 09_reporting_and_summary.sql

Description:
Reporting scripts that generate summary tables for management reporting and
business analysis.

===============================================================================
*/

-- ============================================================================
-- Use Case 16
-- Book Issue Count.
-- ============================================================================
CREATE TABLE book_issue_count AS
	SELECT
		b.isbn,
		b.book_title,
		COUNT(i.issued_id) AS book_count
	FROM books b
	JOIN issued_status i
	ON b.isbn = i.issued_book_isbn
	GROUP BY b.isbn,
			b.book_title;

SELECT * FROM book_issue_count
WHERE book_count > 1;

-- ============================================================================
-- Use Case 17
-- Table of Books with Rental Price Above a Certain Threshold.
-- ============================================================================
CREATE TABLE books_greater_than_7 AS
	SELECT * FROM books
	WHERE rental_price > 7;

-- ============================================================================
-- Use Case 18
-- Table of Active Members.
-- ============================================================================
CREATE TABLE active_members AS
SELECT 
	m.member_id, 
	m.member_name 
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month';

-- ============================================================================
-- Use Case 19
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
-- Use Case 20
/*
Overdue books and calculation of fines.
Table that lists each member and the books they have issued but not returned within 30 days.
The table includes: The number of overdue books. The total fines, with each day's fine calculated at $0.50.
The number of books issued by each member.The resulting table shows: Member ID Number of overdue books Total fines
*/
-- ============================================================================
CREATE TABLE overdue_books_summary AS
SELECT 
	m.member_id,
	COUNT(i.issued_id) AS no_of_overdue_books,
	SUM(
		CASE
			WHEN r.return_date IS NULL THEN
				(CURRENT_DATE - i.issued_date - 30) * 0.50
			ELSE
				(r.return_date - issued_date - 30) * 0.50
		END
	) AS total_fine
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
LEFT JOIN returned_status r
ON i.issued_id = r.issued_id

WHERE 
(
	r.return_date IS NULL 
	AND CURRENT_DATE - i.issued_date > 30
)
OR
(
	r.return_date IS NOT NULL
	AND r.return_date - i.issued_date > 30
)
GROUP BY m.member_id;
