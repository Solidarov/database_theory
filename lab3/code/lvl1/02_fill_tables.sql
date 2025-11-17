INSERT INTO doc_authors (first_name, middle_name, last_name, birth_year, country) VALUES
('George', 'R. R.', 'Martin', 1948, 'USA'),
('Joanne', NULL, 'Rowling', 1965, 'UK'),
('Haruki', NULL, 'Murakami', 1949, 'Japan'),
('Stephen', 'Edwin', 'King', 1947, 'USA'),
('Andrzej', NULL, 'Sapkowski', 1948, 'Poland'),
('J.R.R.', NULL, 'Tolkien', 1892, 'UK'),
('Agatha', 'Mary Clarissa', 'Christie', 1890, 'UK'),
('Frank', 'Patrick', 'Herbert', 1920, 'USA'),
('Isaac', NULL, 'Asimov', 1920, 'USA'),
('Ursula', 'K.', 'Le Guin', 1929, 'USA');

INSERT INTO doc_readers (first_name, last_name, email, phone_number, birth_date, library_card_number) VALUES
('Alice', 'Smith', 'alice@example.com', '555-1234', '2019-05-10', 'LCARD_001'),
('Bob', 'Johnson', 'bob@example.com', '555-5678', '2020-02-15', 'LCARD_002'),
('Charlie', 'Brown', 'charlie@example.com', '555-9012', '2019-11-30', 'LCARD_003'),
('David', 'Lee', 'david@example.com', '555-3456', '2021-07-22', 'LCARD_004'),
('Eva', 'Williams', 'eva@example.com', '555-7890', '2020-09-05', 'LCARD_005'),
('Fiona', 'Glen', 'fiona@example.com', '555-1122', '2019-03-14', 'LCARD_006'),
('George', 'Harris', 'george@example.com', '555-3344', '2020-08-01', 'LCARD_007'),
('Hannah', 'Ivanov', 'hannah@example.com', '555-5566', '2021-01-20', 'LCARD_008'),
('Ian', 'Jones', 'ian@example.com', '555-7788', '2019-06-19', 'LCARD_009'),
('Jane', 'King', 'jane@example.com', '555-9900', '2020-12-12', 'LCARD_010');

INSERT INTO doc_books (isbn, author_id, title, book_description, publication_year, genre, total_copies, available_copies) VALUES
('978-0553103540', 1, 'A Game of Thrones', 'The first book in A Song of Ice and Fire.', 1996, 'Fantasy', 10, 9),
('978-0747532699', 2, 'Harry Potter and the Philosopher''s Stone', 'The first book in the Harry Potter series.', 1997, 'Fantasy', 15, 15),
('978-0394561895', 3, 'Norwegian Wood', 'A nostalgic story of loss and sexuality.', 1987, 'Fiction', 5, 4),
('978-0385121675', 4, 'The Shining', 'A family heads to an isolated hotel for the winter.', 1977, 'Horror', 7, 7),
('978-0575077159', 5, 'The Last Wish', 'A collection of short stories in The Witcher series.', 1993, 'Fantasy', 8, 7),
('978-0553108033', 1, 'A Clash of Kings', 'The second book in A Song of Ice and Fire.', 1998, 'Fantasy', 10, 10),
('978-0618640157', 6, 'The Fellowship of the Ring', 'The first book in The Lord of the Rings.', 1954, 'Fantasy', 12, 11),
('978-0062073488', 7, 'And Then There Were None', 'Ten strangers are lured to an isolated island.', 1939, 'Mystery', 9, 9),
('978-0441172719', 8, 'Dune', 'A story of a noble family in a distant future.', 1965, 'Sci-Fi', 10, 8),
('978-0553293357', 9, 'Foundation', 'The first book in the Foundation series.', 1951, 'Sci-Fi', 6, 6),
('978-0441005908', 4, 'It', 'A terrifying entity preys on the children of Derry.', 1986, 'Horror', 5, 5);

INSERT INTO op_loans (reader_id, book_id, loan_date, due_date, returned_date) VALUES
(1, 3, '2025-11-01', '2025-11-22', NULL),
(2, 1, '2025-11-10', '2025-12-01', NULL),
(3, 5, '2025-11-12', '2025-12-03', NULL),
(4, 6, '2025-10-01', '2025-10-22', '2025-10-20'),
(1, 4, '2025-09-15', '2025-10-06', '2025-10-05'),
(6, 7, '2025-11-13', '2025-12-04', NULL),
(7, 9, '2025-11-14', '2025-12-05', NULL),
(8, 2, '2025-10-30', '2025-11-20', '2025-11-15'),
(9, 8, '2025-11-05', '2025-11-26', '2025-11-11'),
(10, 10, '2025-11-01', '2025-11-22', NULL);
