SELECT 
    isbn, 
    title, 
    book_description,
    publication_year,
    total_copies,
    available_copies
FROM doc_books
WHERE book_id = 4;


UPDATE doc_books
SET
    isbn = '978-1444723557',
    title = 'Thinner',
    book_description = NULL,
    publication_year = 2012,
    total_copies = 5,
    available_copies = 0
WHERE book_id = 4
RETURNING 
    book_id,
    isbn, 
    title, 
    book_description,
    publication_year,
    total_copies,
    available_copies;


SELECT 
    isbn, 
    title, 
    book_description,
    publication_year,
    total_copies,
    available_copies
FROM doc_books
WHERE book_id = 4;

