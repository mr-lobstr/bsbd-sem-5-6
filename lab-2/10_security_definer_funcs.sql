SET ROLE app_owner;

CREATE TABLE audit.function_calls(
    id SERIAL PRIMARY KEY,
    function_name VARCHAR(100) NOT NULL,
    call_time TIMESTAMP NOT NULL DEFAULT current_timestamp,
    caller_role VARCHAR(30) NOT NULL DEFAULT session_user,
    success BOOLEAN NOT NULL DEFAULT FALSE,
    input_params JSONB NOT NULL 
);

COMMENT ON TABLE audit.function_calls
IS 'История вызовов SECURITY DEFINER функций';


CREATE OR REPLACE FUNCTION ref.create_address_from_raw(
    raw_address_id INTEGER,
    region_ VARCHAR(50),
    locality_ VARCHAR(50),
    street_ VARCHAR(50),
    house_number_ INTEGER,
    fraction_ INTEGER,
    building_ VARCHAR(10) DEFAULT NULL
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = ref, stg, audit
LANGUAGE plpgsql
AS $$
DECLARE
    function_call_id INTEGER;
    raw_address_normalized BOOLEAN := NULL;
    new_address_id INTEGER;
BEGIN
    INSERT INTO audit.function_calls(
        function_name,
        input_params
    ) VALUES (
        'create_address_from_raw',
        jsonb_build_object(
            'raw_address_id', raw_address_id,
            'region_', region_,
            'locality_', locality_,
            'street_', street_,
            'house_number_', house_number_,
            'fraction_', fraction_,
            'building_', building_
        )
    ) RETURNING id INTO function_call_id;

    BEGIN
        IF raw_address_id IS NULL
            OR region_ IS NULL
            OR locality_ IS NULL
            OR street_ IS NULL
            OR house_number_ IS NULL
        THEN
            RAISE EXCEPTION
                'Ошибка: id необработанного адреса, регион, район, улица и номер дома не могут быть NULL';
        END IF;

        SELECT normalized
        INTO raw_address_normalized
        FROM stg.raw_addresses
        WHERE id = raw_address_id;

        IF raw_address_normalized IS NULL THEN
            RAISE EXCEPTION
                'Ошибка: не существует записи в raw_addresses с id = %',
                raw_address_id;
        END IF;

        IF NOT raw_address_normalized THEN
            RAISE EXCEPTION
                'Ошибка: необработанный адрес с id = % не прошел нормализацию',
                raw_address_id;
        END IF;

        INSERT INTO ref.addresses(
            region,
            locality,
            street,
            house_number,
            fraction,
            building
        ) VALUES (
            region_,
            locality_,
            street_,
            house_number_,
            fraction_,
            building_
        ) RETURNING id INTO new_address_id;

        UPDATE stg.raw_addresses
        SET created_address_id = new_address_id
        WHERE id = raw_address_id;

        UPDATE audit.function_calls
        SET success = true
        WHERE id = function_call_id;

        RETURN jsonb_build_object(
            'success', true,
            'created_address_id', new_address_id
        );
    EXCEPTION WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_message', SQLERRM
        );
    END;
END;
$$;

COMMENT ON FUNCTION ref.create_address_from_raw
IS 'Создание нового адреса здания на основе данных из внешнего источника';


CREATE OR REPLACE FUNCTION app.create_client_from_raw(
    raw_client_id INTEGER,
    surname_ VARCHAR(30),
    name_ VARCHAR(30),
    middle_name_ VARCHAR(30),
    client_address_id_ INTEGER,
    date_of_birth_ DATE DEFAULT NULL,
    personal_phone_ VARCHAR(12) DEFAULT NULL
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = app, stg, audit
LANGUAGE plpgsql
AS $$
DECLARE
    function_call_id INTEGER;
    raw_client_normalized BOOLEAN := NULL;
    client_address_id INTEGER := NULL;
    new_client_id INTEGER;
BEGIN
    INSERT INTO audit.function_calls(
        function_name,
        input_params
    ) VALUES (
        'create_client_from_raw',
        jsonb_build_object(
            'raw_client_id', raw_client_id,
            'surname_', surname_,
            'name_', name_,
            'middle_name_', middle_name_,
            'client_address_id_', client_address_id_,
            'date_of_birth_', date_of_birth_,
            'personal_phone_', personal_phone_
        )
    ) RETURNING id INTO function_call_id;

    BEGIN
        IF raw_client_id IS NULL
            OR surname_ IS NULL
            OR name_ IS NULL
            OR client_address_id_ IS NULL
        THEN
            RAISE EXCEPTION
                'Ошибка: id необработанных данных клиента, фамилия, имя, id адреса клиента не могут быть NULL';
        END IF;

        SELECT normalized
        INTO raw_client_normalized
        FROM stg.raw_clients
        WHERE id = raw_client_id;

        IF raw_client_normalized IS NULL THEN
            RAISE EXCEPTION
                'Ошибка: не существует записи в raw_clients с id = %',
                raw_client_id;
        END IF;

        IF NOT raw_client_normalized THEN
            RAISE EXCEPTION
                'Ошибка: необработанные данные с id = % не прошли нормализацию',
                raw_client_id;
        END IF;

        SELECT id
        INTO client_address_id
        FROM app.client_addresses
        WHERE id = client_address_id_;

        IF client_address_id IS NULL THEN
            RAISE EXCEPTION
                'Ошибка: не существует записи в client_addresses с id = %',
                client_address_id_;
        END IF;

        INSERT INTO app.clients(
            surname,
            name,
            middle_name,
            client_address_id,
            date_of_birth,
            personal_phone
        ) VALUES (
            surname_,
            name_,
            middle_name_,
            client_address_id_,
            date_of_birth_,
            personal_phone_
        ) RETURNING id INTO new_client_id;

        UPDATE stg.raw_clients
        SET created_client_id = new_client_id
        WHERE id = raw_client_id;

        UPDATE audit.function_calls
        SET success = true
        WHERE id = function_call_id;

        RETURN jsonb_build_object(
            'success', true,
            'created_client_id', new_client_id
        );
    EXCEPTION WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error_message', SQLERRM
        );
    END;
END;
$$;

COMMENT ON FUNCTION app.create_client_from_raw
IS 'Создание нового клиента на основе данных из внешнего источника';


GRANT EXECUTE
    ON FUNCTION ref.create_address_from_raw TO app_writer;

GRANT EXECUTE
    ON FUNCTION app.create_client_from_raw TO app_writer;

RESET ROLE;