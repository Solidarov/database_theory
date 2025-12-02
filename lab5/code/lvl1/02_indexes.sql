-- створити індекси для пошуку клієнта в замовленнях
-- Часто потрібно переглядати замовлення конкретного клієнта
CREATE INDEX idx_ticket_orders_customer_id ON op_ticket_orders(customer_id);

-- складений та частковий індекс по полям payment_status та purchase_time
-- потрібно для спрощення, наприклад, таких запитів:
--      1) потрібно дізнатися неоплачені замовлення користувача
--      2) змінити статус неоплачених протягом n-діб замовлень на 'Abandoned' тощо 
CREATE INDEX idx_orders_statuses
ON op_ticket_orders(payment_status, purchase_time) 
WHERE payment_status != 'Paid';

-- створити індекс для швидшого пошуку квитків згідно замовлення
-- До одного замовлення, можуть бути прикріплені декілька квитків. 
-- Для кращого пошуку по номеру замовлення, додаємо індекс на поле зовнішнього ключа order_id 
CREATE INDEX idx_ticket_order_id ON doc_tickets(order_id);