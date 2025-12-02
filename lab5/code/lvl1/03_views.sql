-- Створити два представлення (VIEW) для спрощення доступу 
-- до часто використовуваних запитів.

-- Вивести інформацію про концерти поточного місяця місяця
CREATE VIEW current_month_events AS
SELECT 
    e.event_id,
    e.event_name,
    a.artist_name,
    s.stage_name,
    e.start_time,  
    e.end_time,
    STRING_AGG(z.zone_name, ' | ' ORDER BY capacity DESC) AS available_scenes
FROM doc_events e
JOIN cat_stages s ON e.stage_id = s.stage_id
JOIN cat_artists a ON e.artist_id = a.artist_id
LEFT JOIN doc_ticket_prices tp ON e.event_id = tp.event_id
LEFT JOIN cat_zones z ON tp.zone_id = z.zone_id
WHERE e.start_time >= date_trunc('month', CURRENT_DATE) 
    AND e.start_time < date_trunc('month', CURRENT_DATE + INTERVAL '1 month')
GROUP BY 
    e.event_id,
    e.event_name,
    a.artist_name,
    s.stage_name,
    e.start_time,  
    e.end_time
ORDER BY e.start_time ASC


-- VIEW для перегляду загального прибутку кожного артиста
CREATE VIEW total_artists_profit AS
SELECT 
    a.artist_name,
    COUNT(t.ticket_id) AS total_sold_tickets_quantity,
    ROUND(SUM(t.price_at_purchase)::numeric / 100, 2) AS total_price
FROM cat_artists a
JOIN doc_events e ON a.artist_id = e.artist_id
JOIN doc_tickets t ON e.event_id = t.event_id
JOIN op_ticket_orders tord ON t.order_id = tord.order_id
WHERE t.ticket_status IN ('Active', 'Used') -- враховуємо тільки активні та використані (тобто теж, які були куплені)
    AND tord.payment_status = 'Paid'
GROUP BY a.artist_id
ORDER BY total_price DESC;
