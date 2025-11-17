BEGIN;

SELECT * FROM doc_books WHERE book_id = 4;
DELETE FROM doc_books WHERE book_id = 4;

ROLLBACK;

COMMIT;