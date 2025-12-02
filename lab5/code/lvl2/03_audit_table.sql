-- створити таблицю для аудиту змін
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

-- розширимо функціонал попередньої функцію log_event_changes
-- щоб мати змогу записувати зміни не тільки для doc_events
-- але й для інших теж
CREATE OR REPLACE FUNCTION log_event_changes() 
RETURNS TRIGGER AS $$
DECLARE 
    rec_id INTEGER;
BEGIN
    IF (TG_TABLE_NAME = 'doc_events') THEN
        rec_id := COALESCE(NEW.event_id, OLD.event_id);
    
    ELSIF (TG_TABLE_NAME = 'doc_ticket_prices') THEN
        rec_id := COALESCE(NEW.event_id, OLD.event_id); 
    
    ELSIF (TG_TABLE_NAME = 'op_ticket_orders') THEN
        rec_id := COALESCE(NEW.order_id, OLD.order_id);
    
    ELSIF (TG_TABLE_NAME = 'cat_customers') THEN
        rec_id := COALESCE(NEW.customer_id, OLD.customer_id);
    
    ELSIF TG_TABLE_NAME = 'cat_stages' THEN
        rec_id := COALESCE(NEW.stage_id, OLD.stage_id);
    
    ELSIF TG_TABLE_NAME = 'cat_zones' THEN
        rec_id := COALESCE(NEW.zone_id, OLD.zone_id);
    
    ELSIF TG_TABLE_NAME = 'cat_artists' THEN
        rec_id := COALESCE(NEW.artist_id, OLD.artist_id);
    
    ELSE
        rec_id := 0; -- якщо забули додати таблицю в список
    END IF;

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, new_data)
        VALUES (TG_TABLE_NAME, 'INSERT', rec_id, row_to_json(NEW)::JSONB);
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data, new_data)
        VALUES (TG_TABLE_NAME, 'UPDATE', rec_id, row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO op_audit_log (changed_table, action_type, record_id, old_data)
        VALUES (TG_TABLE_NAME, 'DELETE', rec_id, row_to_json(OLD)::JSONB);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- тригер для doc_ticket_prices
CREATE TRIGGER doc_ticket_prices_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON doc_ticket_prices
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();

-- тригер для op_ticket_orders
CREATE TRIGGER op_ticket_orders_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON op_ticket_orders
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();

-- тригер для cat_customers
CREATE TRIGGER cat_customers_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON cat_customers
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();

-- тригер для cat_stages
CREATE TRIGGER cat_stages_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON cat_stages
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();

-- тригер для cat_zones
CREATE TRIGGER cat_zones_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON cat_zones
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();

-- тригер для cat_artists
CREATE TRIGGER cat_artists_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON cat_artists
FOR EACH ROW
EXECUTE FUNCTION log_event_changes();



-- ================ ТЕСТИ ================
INSERT INTO cat_artists (artist_name, genre) VALUES ('Test Audit Band', 'Rock');

UPDATE doc_ticket_prices 
SET price = 155000 
WHERE event_id = 1 AND zone_id = 1;

UPDATE cat_customers 
SET first_name = 'Ivan_Updated' 
WHERE customer_id = 1;

-- фінальний огляд логів
SELECT * FROM op_audit_log ORDER BY changed_at DESC LIMIT 5;