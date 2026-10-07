SET ROLE app_owner;

CREATE FUNCTION app.price_update_after_tariff_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE change_n INTEGER;
BEGIN
    IF OLD.price_1 != NEW.price_1
        OR OLD.weight_limit_1_g != NEW.weight_limit_1_g
    THEN
        change_n := 1;
    ELSIF OLD.price_2 != NEW.price_2
        OR OLD.weight_limit_2_g != NEW.weight_limit_2_g
    THEN
        change_n := 2;
    ELSIF OLD.price_3 != NEW.price_3
        OR OLD.additional_weight_g != NEW.additional_weight_g
    THEN
        change_n := 3;
    ELSE
        change_n := 4;
    END IF;

    UPDATE app.orders AS o_
    SET price = app.price_calc_with_discounts(o_.departure_id, o_.delivery_id)
    FROM app.orders o
    JOIN app.departures dp
        ON dp.id = o.departure_id
    JOIN app.delivery d
        ON d.id = o.delivery_id
    WHERE o_.id = o.id
        AND o.paid_at IS NULL
        AND dp.type_id = NEW.departure_type_id
        AND d.route_id = NEW.route_id
        AND (
            change_n = 1 AND dp.weight_g <= OLD.weight_limit_1_g
         OR change_n = 2 AND dp.weight_g > OLD.weight_limit_1_g
         OR change_n = 3 AND dp.weight_g > OLD.weight_limit_2_g
         OR change_n = 4
        );

    RETURN NEW;
END;
$$;


CREATE TRIGGER price_update_after_tariff_change_trg
AFTER UPDATE
ON ref.tariffs
FOR EACH ROW
EXECUTE FUNCTION app.price_update_after_tariff_change();

RESET ROLE;