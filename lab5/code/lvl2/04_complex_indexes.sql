-- створення складеного індексу для кращої роботи тригера check_event_time()
-- Тригер check_event_time() спрацьовує, при оновленні даних або при додаванні нових. 
-- Щоб перевірити, чи існують записи в подібному часовому проміжку, 
-- він шукає дані по stage_id та start_time
CREATE INDEX idx_events_start_time ON doc_events(stage_id, start_time);