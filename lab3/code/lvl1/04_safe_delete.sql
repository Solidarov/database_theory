-- шукаємо автора, в якого не має жодної запису про книгу в бд

SELECT
    a.author_id
FROM
    doc_authors a
LEFT JOIN
    doc_books b ON a.author_id = b.author_id
WHERE
    title IS NULL;

DELETE FROM 
    doc_authors
WHERE
    author_id IN (
        SELECT
            a.author_id
        FROM
            doc_authors a
        LEFT JOIN
            doc_books b ON a.author_id = b.author_id
        WHERE
            title IS NULL
    );
