-- транзакція повертає книгу та перевіряє чи є резервація
-- Якщо є, то змінює її статус і резервує книжку
-- Якщо ні, то додає +1 доступну книжку

DO $$
DECLARE
    t_book_id INTEGER;
    t_reservation_id INTEGER;

BEGIN
    -- записати номер книги у змінну t_book_id
    SELECT book_id INTO t_book_id
    FROM op_loans 
    WHERE loan_id = 2;

    -- вказати час повернення книги
    UPDATE op_loans
    SET returned_date = CURRENT_DATE
    WHERE loan_id = 2 AND returned_date IS NULL;

    -- записати номер резервації (якщо існує) у змінну t_reservation_id
    SELECT reservation_id INTO t_reservation_id
    FROM op_reservation
    WHERE book_id = t_book_id AND reservation_status = 'Active'
    ORDER BY reservation_date
    LIMIT 1;

    -- якщо замовлення існує
    IF t_reservation_id IS NOT NULL THEN
        
        -- змінити статус замовлення на Fullfiled
        UPDATE op_reservation
        SET reservation_status = 'Fullfiled'
        WHERE reservation_id = t_reservation_id;

        -- збільшити кількість зарезервованих книг на 1
        UPDATE doc_books
        SET reserved_copies = reserved_copies + 1
        WHERE book_id = t_book_id;

        RAISE NOTICE 'Book ID % returned and fulfilled reservation %', t_book_id, t_reservation_id;
    
    -- якщо замовлення не існує
    ELSE
        
        -- збільшити кількість доступних книг на 1
        UPDATE doc_books
        SET available_copies = available_copies - 1
        WHERE book_id = t_book_id;

        RAISE NOTICE 'Book ID % returned and is now available', t_book_id;
    
    END IF;

END;
$$;