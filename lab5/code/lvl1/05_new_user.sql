-- Створюємо користувача для роботи з таблицями 
-- cat_artists, cat_stages, cat_zones, doc_events,doc_ticket_prices

-- фактичне створення користувача
CREATE USER content_manager WITH PASSWORD 'secure_password_123';

-- створюємо роль content_manager та підключаємо до БД
GRANT CONNECT ON DATABASE concert_place TO content_manager;

-- надаємо права користуватися SCHEMA public
GRANT USAGE ON SCHEMA public TO content_manager;

-- фактично надаємо права на таблиці контенту
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE 
    cat_artists, 
    cat_stages, 
    cat_zones, 
    doc_events, 
    doc_ticket_prices
TO content_manager;

GRANT INSERT ON TABLE op_audit_log TO content_manager;


-- надаємо також права на SEQUENCE, щоб можна було додавати дані
-- в таблицю, де використовується, напр., SERIAL PRIMARY KEY
GRANT USAGE, SELECT ON SEQUENCE 
    cat_artists_artist_id_seq,
    cat_stages_stage_id_seq,
    cat_zones_zone_id_seq,
    doc_events_event_id_seq,
    op_audit_log_log_id_seq
TO content_manager;


-- =========== ТЕСТИ ===========
-- Змінюємо поточну роль на менеджера
SET ROLE content_manager;

-- Пробуємо подивитися артистів (Має спрацювати)
SELECT * FROM cat_artists;

-- Пробуємо додати артиста (Має спрацювати, якщо є права на Sequence)
INSERT INTO cat_artists (artist_name, genre) VALUES ('Test Band', 'Rock');

-- Пробуємо подивитися клієнтів (МАЄ БУТИ ПОМИЛКА: Permission denied)
SELECT * FROM cat_customers;

-- Повертаємося назад у роль суперюзера (root)
RESET ROLE;