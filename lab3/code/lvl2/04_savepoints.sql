BEGIN;

INSERT INTO doc_authors (first_name, last_name, birth_year, country) 
VALUES ('Chinua', 'Achebe', 1930, 'Nigeria');

SAVEPOINT after_add_author;

-- буде помилка, так як доступних копій більше за загальну кількість
INSERT INTO doc_books (isbn, author_id, title, publication_year, genre, total_copies, available_copies) 
VALUES ('978-0385474542', CURRVAL('doc_authors_author_id_seq'), 'Things Fall Apart', 1958, 'Fiction', 5, 6);

ROLLBACK TO SAVEPOINT after_add_author;

INSERT INTO doc_books (isbn, author_id, title, publication_year, genre, total_copies, available_copies) 
VALUES ('978-0385474542', CURRVAL('doc_authors_author_id_seq'), 'Things Fall Apart', 1958, 'Fiction', 5, 5);

COMMIT;
