-- Складне представлення, що дозволяє редагувати час події та 
-- ціну квитка VIP зони в одному місці за допомогою Rules

CREATE OR REPLACE VIEW v_event_vip_pricing AS
SELECT
    e.event_id,
    e.event_name,
    e.start_time,
    ROUND((tp.price)::numeric / 100, 2) AS vip_price
FROM doc_events e
JOIN doc_ticket_prices tp ON e.event_id = tp.event_id
WHERE tp.zone_id = 3;


CREATE RULE update_event_vip_price_n_time AS
ON UPDATE TO v_event_vip_pricing
DO INSTEAD (
    UPDATE doc_events 
    SET start_time = NEW.start_time 
    WHERE event_id = OLD.event_id;
    
    UPDATE doc_ticket_prices 
    SET price = (NEW.vip_price * 100)::INTEGER 
    WHERE event_id = OLD.event_id 
        AND zone_id = 3;
);


-- ============= ТЕСТИ =============

-- 2026-06-20 20:00 | vip ticket: 3000.00 
SELECT * 
FROM v_event_vip_pricing 
WHERE event_id = 1;

-- змінюємо ціну на 4000.50
UPDATE v_event_vip_pricing
SET vip_price = 4000.50
WHERE event_id = 1;

-- перевіряємо чи ціну було змінено
SELECT price 
FROM doc_ticket_prices 
WHERE event_id = 1 
    AND zone_id = 3;

