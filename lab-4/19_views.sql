SET ROLE app_owner;

CREATE VIEW app.client_addresses_for_postal_delivery AS
SELECT
    id,
    address_id,
    flat,
    entrance,
    has_mailbox
FROM app.client_addresses
WHERE has_mailbox
WITH CHECK OPTION;

COMMENT ON VIEW app.client_addresses_for_postal_delivery
IS 'Данные адресов клиентов доступные почтальонам';


CREATE VIEW app.client_contact_info AS
SELECT
    id,
    surname,
    name,
    middle_name,
    personal_phone,
    mail
FROM app.clients
WHERE personal_phone IS NOT NULL OR mail IS NOT NULL
WITH CHECK OPTION;

COMMENT ON VIEW app.client_contact_info
IS 'Контактные данные пользователей';


CREATE VIEW app.parcels_dimensions_stats
WITH (security_barrier) AS
SELECT
    office_to_id,

	AVG(weight) AS avg_weight,
	AVG(length) AS avg_length,
	AVG(width) AS avg_width,
	AVG(height) AS avg_height,

	SUM(weight) AS sum_weight,

	MAX(weight) AS max_weight,
	MAX(length) AS max_length,
	MAX(width) AS max_width,
	MAX(height) AS max_height,

	MIN(weight) AS min_weight,
	MIN(length) AS min_length,
	MIN(width) AS min_width,
	MIN(height) AS min_height
FROM app.packages
WHERE type = 'посылка' AND receipt_date IS NOT NULL
GROUP BY office_to_id;

COMMENT ON VIEW app.parcels_dimensions_stats
IS 'Статистика по габаритам посылок';


CREATE VIEW app.current_status_count
WITH (security_barrier) AS
SELECT COUNT(*), status_id
FROM (
	SELECT DISTINCT ON (package_id)
		status_id
	FROM app.status_history
	ORDER BY package_id, date DESC
)
GROUP BY status_id;

COMMENT ON VIEW app.current_status_count
IS 'Количественная оценка текущих статусов посылок';

RESET ROLE;