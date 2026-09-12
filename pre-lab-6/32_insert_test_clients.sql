SET ROLE postgres;

CALL app.request_temp_privilege(
	'postgres',
	'app.client_addresses',
	'INSERT',
	10
);

INSERT INTO app.client_addresses (
    address_id,
    flat,
    floor,
    entrance,
    has_mailbox,
    segment_id
)
SELECT
    (i - 1) % 10 + 1,
    (i - 1) % 100 + 1,
    (i - 1) % 9 + 1,
    (i - 1) % 8 + 1,
    RANDOM()::INTEGER::BOOLEAN,
    1 + RANDOM() * 9
FROM generate_series(1, 1000) i;


WITH names AS (
    SELECT 'Михаил' AS name
    UNION ALL SELECT 'Николай'
    UNION ALL SELECT 'Александр'
    UNION ALL SELECT 'Григорий'
    UNION ALL SELECT 'Максим'
    UNION ALL SELECT 'Олег'
    UNION ALL SELECT 'Владимир'
    UNION ALL SELECT 'Дмитрий'
    UNION ALL SELECT 'Иван'
    UNION ALL SELECT 'Павел'
), surnames AS (
    SELECT 'Петров' AS surname
    UNION ALL SELECT 'Иванов'
    UNION ALL SELECT 'Смирнов'
    UNION ALL SELECT 'Кузнецов'
    UNION ALL SELECT 'Попов'
    UNION ALL SELECT 'Соколов'
    UNION ALL SELECT 'Лебедев'
    UNION ALL SELECT 'Новиков'
    UNION ALL SELECT 'Морозов'
    UNION ALL SELECT 'Волков'
), middle_names AS (
    SELECT 'Михаил' AS middle_name
    UNION ALL SELECT 'Николаевич'
    UNION ALL SELECT 'Александрович'
    UNION ALL SELECT 'Григорьевич'
    UNION ALL SELECT 'Максимович'
    UNION ALL SELECT 'Олегович'
    UNION ALL SELECT 'Владимирович'
    UNION ALL SELECT 'Дмитриевич'
    UNION ALL SELECT 'Иванович'
    UNION ALL SELECT 'Павлович'
)
INSERT INTO app.clients (
    surname,
    name,
    middle_name,
    client_address_id,
    segment_id
)
SELECT
    surname,
    name,
    middle_name,
    row_number() OVER (),
    1 + RANDOM() * 9
FROM names
CROSS JOIN surnames
CROSS JOIN middle_names;

RESET ROLE;