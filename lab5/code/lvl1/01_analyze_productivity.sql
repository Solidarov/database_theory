-- Перший запит
-- Дізнаємося інфомацію про всі куплені квитки зі статусом 'Active'
EXPLAIN (ANALYZE)
SELECT 
    t.ticket_id, 
    e.event_name,
    z.zone_name,
    (c.first_name ||' '|| c.last_name) as client_name,
    t.ticket_status,
    CASE
        WHEN t.price_at_purchase < tp.price THEN TRUE ELSE FALSE END as is_discounted,
    t.price_at_purchase,
    tp.price as current_price

FROM doc_tickets t
JOIN doc_events e ON t.event_id = e.event_id
JOIN cat_zones z ON t.zone_id = z.zone_id
JOIN doc_ticket_prices tp ON e.event_id = tp.event_id AND z.zone_id = tp.zone_id
JOIN op_ticket_orders tord ON t.order_id = tord.order_id
JOIN cat_customers c ON tord.customer_id = c.customer_id
WHERE t.ticket_status = 'Active'
ORDER BY ticket_id;

-- Другий запит
-- Прорахувати скільки грошей приніс кожен артист, 
-- враховуючи тільки оплачені замовлення (payment_status = 'Paid')
-- і активні квитки.
EXPLAIN (ANALYZE)
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

-- Третій запит
-- Висвітлити всі квитки конкретного користувача на майбутні події, 
-- відсортовані за датою початку концерту.
EXPLAIN (ANALYZE)
SELECT 
    t.ticket_id,
    e.event_name,
    s.stage_name,
    z.zone_name,
    e.start_time

FROM doc_tickets t
JOIN op_ticket_orders tord ON t.order_id = tord.order_id
JOIN doc_events e ON t.event_id = e.event_id
JOIN cat_stages s ON e.stage_id = s.stage_id
JOIN cat_zones z ON t.zone_id = z.zone_id AND s.stage_id = z.stage_id
WHERE tord.customer_id = 7 
    AND tord.payment_status = 'Paid' 
    AND t.ticket_status = 'Active'
    AND e.start_time > NOW()
ORDER BY e.start_time ASC
