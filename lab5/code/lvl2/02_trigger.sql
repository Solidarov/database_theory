CREATE OR REPLACE FUNCTION validate_customer_email() 
RETURNS TRIGGER AS $$
BEGIN
    -- email не повинен бути просто пробілом
    IF TRIM(NEW.email) = '' THEN
        RAISE EXCEPTION 'Email cannot be empty or just spaces.';
    END IF;

    -- перевіряємо, чи формат електронної адреси правильний за допомогою regular expression
    -- патерн: щось + @ + щось + . + щось
    IF NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %. Please provide a valid email address (e.g., user@example.com).', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_email_format_trigger
BEFORE INSERT OR UPDATE ON cat_customers
FOR EACH ROW
EXECUTE FUNCTION validate_customer_email();


-- ====== Тести ======

-- некоректна електронна адреса
INSERT INTO cat_customers (first_name, last_name, email, password_hash)
VALUES ('Hacker', 'Test', 'bad-email-without-at-symbol', 'hash123');

-- просто пробіл замість електронної адреси (помилка)
UPDATE cat_customers 
SET email = '   ' 
WHERE customer_id = 1;

-- валідна електронна адреса (успішно)
INSERT INTO cat_customers (first_name, last_name, email, password_hash)
VALUES ('Good', 'User', 'valid.user@example.com', 'hash123');
