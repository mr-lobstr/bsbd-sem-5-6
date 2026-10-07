BEGIN;

DO $$
BEGIN
	RAISE NOTICE 'Вставка нового типа';

	INSERT INTO ref.departure_types (
		type,
		subtype,
		max_weight_g
	) VALUES (
		'другое',
		'new type',
		100
	);

	RAISE NOTICE 'Вставка уже существующего типа';

	BEGIN
		INSERT INTO ref.departure_types (
			type,
			subtype,
			max_weight_g
		) VALUES (
			'другое',
			'new type',
			100
		);

		RAISE NOTICE 'Вставка успешна';
	EXCEPTION WHEN OTHERS THEN
    	RAISE NOTICE 'Вставка не удалась: %', SQLERRM;
	END;
END;
$$;

ROLLBACK;