#!/bin/sh
gpg --batch \
    --passphrase "passphrase" \
    --quick-generate-key "1" \
    rsa4096 sign never

FINGERPRINT=$( \
    gpg --with-colons --list-keys "1" \
    | awk -F: '$1 == "fpr" {print $10; exit}' \
)

gpg --batch \
    --pinentry-mode loopback \
    --passphrase "passphrase" \
    --quick-add-key $FINGERPRINT \
    rsa4096 encrypt never

PGP_DIR=/var/lib/postgresql/18/docker/pgp_keys

mkdir $PGP_DIR

gpg --batch \
    --export "1" \
    > $PGP_DIR/public.key

gpg --batch \
    --pinentry-mode loopback \
    --passphrase "passphrase" \
    --export-secret-keys "1" \
    > $PGP_DIR/private.key

chmod 400 $PGP_DIR/private.key