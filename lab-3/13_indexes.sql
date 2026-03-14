SET ROLE app_owner;

CREATE INDEX packages_segment_id_idx ON app.packages(segment_id);
CREATE INDEX packages_id_idx ON app.packages(id);
CREATE INDEX packages_type_idx ON app.packages(type);

CREATE INDEX clients_segment_id_idx ON app.clients(segment_id);
CREATE INDEX clients_idx ON app.clients(id);

CREATE INDEX client_addresses_segment_id_idx ON app.client_addresses(segment_id);
CREATE INDEX client_addresses_id_idx ON app.client_addresses(id);
CREATE INDEX client_addresses_address_id_idx ON app.client_addresses(address_id);

CREATE INDEX status_history_segment_id_idx ON app.status_history(segment_id);
CREATE INDEX status_history_id_idx ON app.status_history(id);
CREATE INDEX status_history_package_id_idx ON app.status_history(package_id);

CREATE INDEX movement_history_segment_idx ON app.movement_history(segment_id);
CREATE INDEX movement_history_id_idx ON app.movement_history(id);
CREATE INDEX movement_history_package_id_idx ON app.movement_history(package_id);

RESET ROLE;