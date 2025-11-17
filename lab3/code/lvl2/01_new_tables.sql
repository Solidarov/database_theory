CREATE TABLE op_reservation(
    reservation_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    reader_id INTEGER NOT NULL,
    reservation_date DATE DEFAULT CURRENT_DATE,
    expiration_date DATE NOT NULL,
    reservation_status VARCHAR(20) DEFAULT 'Active' CHECK (reservation_status IN ('Active', 'Fullfiled', 'Cancelled', 'Expired')),

    FOREIGN KEY (book_id) REFERENCES doc_books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (reader_id) REFERENCES doc_readers(reader_id) ON DELETE CASCADE
);

CREATE TABLE op_audit_log(
    log_id SERIAL PRIMARY KEY,
    changed_table VARCHAR(50) NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    record_id INTEGER NOT NULL,
    changed_by_user VARCHAR(100) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

