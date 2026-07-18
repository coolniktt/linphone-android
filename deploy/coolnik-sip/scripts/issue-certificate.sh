#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

set -a
. ./.env
set +a

: "${SIP_DOMAIN:?SIP_DOMAIN is required in .env}"
: "${CERTBOT_EMAIL:?CERTBOT_EMAIL is required in .env}"

docker compose --profile maintenance run --rm certbot certonly \
  --non-interactive \
  --agree-tos \
  --no-eff-email \
  --email "$CERTBOT_EMAIL" \
  --webroot \
  --webroot-path /var/www/acme \
  --cert-name "$SIP_DOMAIN" \
  --domain "$SIP_DOMAIN"
