SET ROLE app_owner;

CREATE VIEW ref.standard_dimensions
WITH (security_barrier) AS
SELECT
	id,
	width_mm,
	length_mm,
	height_mm,
	size_letters
FROM app.dimensions d
WHERE d.is_standard;

COMMENT ON VIEW ref.standard_dimensions
IS 'Стандартные габариты';


CREATE VIEW app.custom_dimensions
WITH (security_barrier) AS
SELECT
	id,
	width_mm,
	length_mm,
	height_mm
FROM app.dimensions d
WHERE NOT d.is_standard;

COMMENT ON VIEW app.custom_dimensions
IS 'Пользовательские габариты';


CREATE VIEW app.current_statuses
WITH (security_barrier) AS
SELECT
	DISTINCT ON (departure_id) status_id, departure_id
FROM app.status_history
ORDER BY departure_id, date DESC;

COMMENT ON VIEW app.current_statuses
IS 'Пользовательские габариты';


CREATE VIEW app.parcels_dimensions_stats
WITH (security_barrier) AS
SELECT
    r.object_to_id,

	AVG(weight_grams) AS avg_weight_grams,
	AVG(length_mm) AS avg_length_mm,
	AVG(width_mm) AS avg_width_mm,
	AVG(height_mm) AS avg_height_mm,

	SUM(weight_grams) AS sum_weight_grams,

	MAX(weight_grams) AS max_weight_grams,
	MAX(length_mm) AS max_length_mm,
	MAX(width_mm) AS max_width_mm,
	MAX(height_mm) AS max_height_mm,

	MIN(weight_grams) AS min_weight_grams,
	MIN(length_mm) AS min_length_mm,
	MIN(width_mm) AS min_width_mm,
	MIN(height_mm) AS min_height_mm
FROM app.dimensions dim
JOIN app.departures dep ON dep.dimension_id = dim.id
JOIN app.orders o ON o.departure_id = dep.id
JOIN app.delivery del ON del.id = o.delivery_id
JOIN ref.routes r ON r.id = del.route_id
JOIN app.current_statuses cs ON cs.departure_id = dep.id
JOIN ref.statuses s ON s.id = cs.status_id
WHERE closed_at IS NULL AND s.name = 'Прибыла в пункт назначения'
GROUP BY r.object_to_id;

COMMENT ON VIEW app.parcels_dimensions_stats
IS 'Статистика по габаритам посылок';


CREATE VIEW app.current_status_count
WITH (security_barrier) AS
SELECT COUNT(*), status_id
FROM app.current_statuses
GROUP BY status_id;

COMMENT ON VIEW app.current_status_count
IS 'Количественная оценка текущих статусов посылок';

RESET ROLE;