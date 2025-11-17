CREATE OR REPLACE FUNCTION check_available_copies()
RETURNS TRIGGER AS $$
DECLARE
    copies_left INTEGER;
BEGIN
    -- Get the number of copies
    SELECT available_copies INTO copies_left
    FROM doc_books b
    WHERE b.book_id = NEW.book_id; -- <-- ERROR 1: Added semicolon

    -- Check if copies are available
    IF copies_left <= 0 THEN
        -- Stop the transaction if no copies are left
        RAISE EXCEPTION 'No available copies for book_id %', NEW.book_id;
    END IF; -- <-- ERROR 2: Removed the invalid "ELSE;"

    -- ERROR 3: Added RETURN NEW.
    -- If the code reaches this point, the check passed.
    -- Tell the database to proceed with the original INSERT.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_loan_insert
BEFORE INSERT ON op_loans
FOR EACH ROW 
EXECUTE FUNCTION check_available_copies();