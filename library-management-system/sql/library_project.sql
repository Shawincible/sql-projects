-- Creating Database
CREATE DATABASE library_project;

-- Branch Table creation
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(			branch_id VARCHAR(10) PRIMARY KEY,
			manager_id VARCHAR(10),
			branch_address VARCHAR(50),
			contact_no VARCHAR(15)
);

-- Employees Table creation
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
			emp_id	VARCHAR(10) PRIMARY KEY,
			emp_name VARCHAR (25),	
			position VARCHAR (15),
			salary INT,
			branch_id VARCHAR(10) -- FK
);

-- Books Table creation
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

-- Members Table creation
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
			member_id VARCHAR(10) PRIMARY KEY,
			member_name VARCHAR(25),
			member_address VARCHAR(50),
			reg_date DATE
);

-- Issued Status Table creation
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

-- Returned Status Table creation
DROP TABLE IF EXISTS returned_status;
CREATE TABLE returned_status
(
			return_id VARCHAR(10) PRIMARY KEY,
			issued_id VARCHAR(10), -- FK
			return_book_name VARCHAR(60),
			return_date	DATE,
			return_book_isbn VARCHAR(20) -- FK

);

-- Foreign Key

ALTER TABLE issued_status
ADD CONSTRAINT fk_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE returned_status
ADD CONSTRAINT fk_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


-- 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '256 Bidhan Nagar Road'
WHERE member_id = 'C105';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT issued_book_name 
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT(issued_id) AS number_of_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

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

Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Fantasy';

Task 8: Find Total Rental Income by Category

SELECT 
	category, 
	SUM(rental_price) AS total_rents,
	COUNT(*) AS issued
FROM books
GROUP BY category;

Task 9: List Members Who Registered in the Last 180 Days:

SELECT member_id, member_name FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
SELECT 
	e.emp_id,
	e.emp_name,
	m.emp_name AS manager_name,
	b.*
FROM employees e
JOIN branch b
ON e.branch_id = b.branch_id
JOIN employees m
ON m.emp_id = b.manager_id
;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE books_greater_than_7 AS
	SELECT * FROM books
	WHERE rental_price > 7;

SELECT * FROM books_greater_than_7;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT *
FROM issued_status i
LEFT JOIN returned_status r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;

-- Advanced Queries

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
	v_isbn VARCHAR(20);
	v_book_name VARCHAR(50);
	
BEGIN

	INSERT INTO returned_status
	(return_id, issued_id, return_date, book_quality)
	VALUES 
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

	SELECT 
		issued_book_isbn, 
		issued_book_name
	INTO 
		v_isbn, 
		v_book_name
	FROM 
		issued_status
	WHERE
		issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank You for returning the book: %', v_book_name;
	
END;
$$

-- Testing Function

SELECT * FROM books
WHERE status = 'no';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM returned_status
WHERE issued_id = 'IS135';

-- Calling Function
CALL add_return_records('RS120', 'IS135', 'Good');

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals..
*/

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

SELECT * FROM branch_reports;

/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/

CREATE TABLE active_members AS
SELECT 
	m.member_id, 
	m.member_name 
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month';

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT * FROM issued_status;

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

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

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

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/



CREATE OR REPLACE PROCEDURE issue_books(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(20), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
	v_status VARCHAR(10);
BEGIN
	SELECT status
	INTO v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id )
		VALUES
		(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;

	ELSE
		RAISE NOTICE 'Sorry to inform that the book you have requested isbn : % is unavailable', p_issued_book_isbn;
	END IF;
END ;
$$

-- Testing the function

SELECT * FROM books;
-- 978-0-330-25864-8 (yes)
-- 978-0-7432-7357-1 (no)

SELECT * FROM issued_status;

CALL issue_books('IS155', 'C110', '978-0-330-25864-8', 'E106');
CALL issue_books('IS155', 'C110', '978-0-7432-7357-1', 'E106');

/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member.The resulting table should show: Member ID Number of overdue books Total fines
*/

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











