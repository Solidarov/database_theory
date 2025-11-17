BEGIN;

SELECT * 
FROM doc_readers 
WHERE reader_id = 2 
FOR UPDATE;

SELECT pg_sleep(10);

UPDATE doc_readers 
SET middle_name = 'William'
WHERE reader_id = 2;

COMMIT;

BEGIN;

SELECT *
FROM doc_readers
WHERE reader_id = 2
FOR UPDATE;

UPDATE doc_readers
SET middle_name = NULL
WHERE reader_id = 2;

COMMIT;
