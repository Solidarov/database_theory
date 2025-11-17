CREATE TABLE doc_authors(
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    birth_year INTEGER CHECK (birth_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doc_books(
    book_id SERIAL PRIMARY KEY,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    author_id INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    book_description TEXT,
    publication_year INTEGER CHECK (publication_year >= 1800 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    genre VARCHAR(50),
    total_copies INTEGER DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INTEGER DEFAULT 1 CHECK (available_copies >= 0),
    reserved_copies INTEGER DEFAULT 0 CHECK (reserved_copies >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   

    FOREIGN KEY (author_id) REFERENCES doc_authors(author_id) ON DELETE RESTRICT,
    CHECK (available_copies <= total_copies AND reserved_copies <= total_copies)
);

CREATE TABLE doc_readers(
    reader_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    birth_date DATE CHECK (birth_date >= '2019-01-01'),
    library_card_number VARCHAR(20) UNIQUE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE, 
    reader_status VARCHAR(20) DEFAULT 'Active' CHECK (reader_status in ('Active', 'Blocked', 'Inactive'))
);

CREATE TABLE op_loans(
    loan_id SERIAL PRIMARY KEY,
    reader_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    returned_date DATE,

    FOREIGN KEY (reader_id) REFERENCES doc_readers(reader_id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES doc_books(book_id) ON DELETE RESTRICT,

    CHECK (due_date > loan_date),
    CHECK (returned_date IS NULL OR returned_date >= loan_date) 
);