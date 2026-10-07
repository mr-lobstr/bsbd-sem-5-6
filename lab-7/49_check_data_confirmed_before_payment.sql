-- SET ROLE app_owner;

-- CREATE FUNCTION app.check_data_confirmed_before_payment()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1
--         FROM app.status_history sh
--         JOIN ref.statuses s ON s.id = sh.status_id
--         WHERE s.name = 'Данные подтверждены'
--             AND sh.departure_id = NEW.departure_id
--     ) THEN
--         RAISE EXCEPTION
--             'Оплата не может быть произведена, пока данные отправления не подтверждены';
--     END IF;

--     RETURN NEW;
-- END;
-- $$;


-- CREATE TRIGGER check_data_confirmed_before_payment_trg
-- BEFORE INSERT
--     OR UPDATE
-- ON app.orders
-- FOR EACH ROW
-- EXECUTE FUNCTION app.check_data_confirmed_before_payment();

-- RESET ROLE;