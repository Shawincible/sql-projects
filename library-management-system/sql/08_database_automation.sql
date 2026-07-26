/*
===============================================================================
Project      : Enterprise Library Management System
File         : 08_database_automation.sql

Description:
Implements reusable stored procedures for automating common business processes.

===============================================================================
*/

-- ============================================================================
-- Use Case 14
-- Update Book Status Automatically on Return.
-- ============================================================================
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
	
-- ============================================================================
-- Use Case 15
/*
Updating the status of a book in the library based on its issuance.
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available
*/
-- ============================================================================

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
