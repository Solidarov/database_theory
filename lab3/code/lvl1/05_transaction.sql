BEGIN;

INSERT INTO op_loans (reader_id, book_id, due_date, returned_date)
VALUES (5, 4, (CURRENT_DATE + INTERVAL '30 days'), NULL);

UPDATE doc_books
SET available_copies = available_copies - 1
WHERE book_id = 4 AND available_copies > 0;

SELECT * 
FROM op_loans 
WHERE loan_id = LASTVAL();

SELECT * 
FROM doc_books 
WHERE book_id = 4;

COMMIT;