BEGIN;

-- вставити нового тестового користувача
INSERT INTO doc_readers (first_name, last_name, email, phone_number, birth_date, library_card_number, registration_date, reader_status)
VALUES ('Olena', 'Petrenko', 'olena.p@example.com', '555-1111', '2019-06-20', 'LCARD_012', '2025-11-16', 'Inactive')
RETURNING first_name, last_name, email, phone_number, birth_date, library_card_number, registration_date, reader_status;

-- вставити першу тестову книгу
INSERT INTO doc_books (isbn, author_id, title, publication_year, genre, total_copies, available_copies)
VALUES ('978-0123456789', 1, 'Test Book Title', 2024, 'Testing', 1, 1)
RETURNING isbn, author_id, title, publication_year, genre, total_copies, available_copies;

-- вставити тестові резервації
INSERT INTO op_reservation (book_id, reader_id, expiration_date, reservation_status)
VALUES 
    (CURRVAL('doc_books_book_id_seq') , CURRVAL('doc_readers_reader_id_seq'), (CURRENT_DATE + INTERVAL '14 days'), 'Active'),
    (1 , CURRVAL('doc_readers_reader_id_seq'), (CURRENT_DATE + INTERVAL '14 days'), 'Active')
RETURNING book_id, reader_id, expiration_date, reservation_status;

COMMIT;


DO $$
DECLARE
    v_reader_id INTEGER;
    v_book_id INTEGER;
BEGIN

    -- вибрати останнього стореного користувача з неактивним статусом 
    SELECT reader_id INTO v_reader_id
    FROM doc_readers
    WHERE reader_status = 'Inactive'
    ORDER BY registration_date
    LIMIT 1;

    -- вибрати останню створену книгу
    SELECT book_id INTO v_book_id
    FROM doc_books
    WHERE title LIKE '%Test%'
    ORDER BY created_at DESC
    LIMIT 1;

    -- видалити тестову книжку із усіма резерваціями
    DELETE FROM doc_books WHERE book_id = v_book_id;
    RAISE NOTICE 'All reservation records related to % book_id were successfully deleted!', v_book_id;

    -- видалити тестового користувача із усіма резерваціями
    DELETE FROM doc_readers WHERE reader_id = v_reader_id;
    RAISE NOTICE 'All reservation records related to % reader_id were successfully deleted!', v_reader_id;

END;
$$;