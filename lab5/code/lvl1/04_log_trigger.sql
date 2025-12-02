-- Розробити тригер для автоматичного логування операцій вставки 
-- або оновлення в одній з таблиць.
-- таблиця для логування змін: op_audit_log


CREATE OR REPLACE FUNCTION log_event_changes() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, new_data)
        VALUES (TG_TABLE_NAME, 'INSERT', NEW.event_id, row_to_json(NEW)::JSONB);
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data, new_data)
        VALUES (TG_TABLE_NAME, 'UPDATE', NEW.event_id, row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data)
        VALUES (TG_TABLE_NAME, 'DELETE', OLD.event_id, row_to_json(OLD)::JSONB);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER doc_events_log_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON doc_events
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();



-- ====== Тести ======
-- 1. Вставка (INSERT)
INSERT INTO doc_events (event_name, stage_id, artist_id, start_time, end_time)
VALUES ('Test Audit Concert', 1, 1, '2026-09-01 20:00', '2026-09-01 22:00');

-- 2. Оновлення (UPDATE) - змінимо час
UPDATE doc_events 
SET start_time = '2026-09-01 21:00' 
WHERE event_name = 'Test Audit Concert';

-- 3. Видалення (DELETE)
DELETE FROM doc_events 
WHERE event_name = 'Test Audit Concert';    

-- 4. Перевірка результату
SELECT * FROM op_audit_log ORDER BY log_id DESC LIMIT 3;




