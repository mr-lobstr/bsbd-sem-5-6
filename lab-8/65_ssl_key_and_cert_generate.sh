#!/bin/sh
SSL_DIR=/etc/postgresql/ssl
CONF=var/lib/postgresql/18/docker/postgresql.conf
HBA_CONF=var/lib/postgresql/18/docker/pg_hba.conf

mkdir $SSL_DIR

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=RU/ST=S/L=L/O=O/OU=D/CN=localhost" \
    -keyout $SSL_DIR/server.key \
    -out $SSL_DIR/server.crt

echo 'ssl = on' >> $CONF
echo "ssl_cert_file = '$SSL_DIR/server.crt'" >> $CONF
echo "ssl_key_file = '$SSL_DIR/server.key'" >> $CONF

chmod 400 $SSL_DIR/server.key

sed -i 's/host/hostssl/' "$HBA_CONF"