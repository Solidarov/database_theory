CREATE OR REPLACE FUNCTION log_readers_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, new_data)
        VALUES ('doc_readers', 'INSERT', NEW.reader_id, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data, new_data)
        VALUES ('doc_readers', 'UPDATE', NEW.reader_id, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data)
        VALUES ('doc_readers', 'DELETE', NEW.reader_id, row_to_json(OLD)::jsonb);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_readers_audit
AFTER INSERT OR UPDATE OR DELETE ON doc_readers
FOR EACH ROW
EXECUTE FUNCTION log_readers_changes();


UPDATE doc_readers 
SET phone_number = '555-9900' 
WHERE reader_id = 10 
RETURNING
    first_name,
    last_name,
    phone_number;

SELECT 
    log_id, action_type, record_id,
    old_data ->> 'first_name' AS first_name,
    old_data ->> 'middle_name' AS middle_name,
    old_data ->> 'last_name' AS last_name,
    old_data ->> 'phone_number' AS old_phone_number,
    new_data ->> 'phone_number' AS new_phone_number
FROM 
    op_audit_log
WHERE 
    changed_table = 'doc_readers'
ORDER BY 
    changed_at DESC;