#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

docker compose --profile maintenance run --rm certbot renew \
  --quiet \
  --webroot \
  --webroot-path /var/www/acme \
  --deploy-hook "touch /var/lib/coolnik-sip/reload-required"

if [ -f tls/reload-required ]; then
  docker compose restart flexisip
  rm -f tls/reload-required
fi
