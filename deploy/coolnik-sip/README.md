# Coolnik SIP and Android push

This Compose project runs the public Flexisip registrar for `sip.coolnik.ru`,
persists mobile registrations in Redis, and sends Android wake-up pushes through
Firebase Cloud Messaging HTTP v1.

## Call path

```text
GSM / AI agent -> Asterisk -> authenticated SIP trunk -> Flexisip -> FCM -> Coolnik Phone
```

Asterisk remains the GSM/media bridge. Flexisip owns the public mobile
registration, stores RFC 8599 push parameters, holds an incoming INVITE, sends
the FCM wake-up event, and routes the call after the Android client re-registers.

## Server layout

The deployment lives entirely under `/opt/docker/coolnik-sip`:

- `docker-compose.yml`, `Dockerfile`, `.env`: runtime definition;
- `config/flexisip.conf`: non-secret SIP and push configuration;
- `secrets/firebase-service-account.json`: FCM sender key, mode `0600`;
- `secrets/users.conf`: SIP credentials, mode `0600`;
- `data/redis`: persistent registrar data;
- `data/flexisip`: persistent Flexisip state;
- `tls/letsencrypt`: the SIP TLS certificate and renewal state;
- `logs`: Flexisip logs.

Secret files are deliberately excluded from Git and must never be copied into
the Android APK or Docker image.

## Operations

```bash
cd /opt/docker/coolnik-sip
docker compose config --quiet
docker compose build --pull flexisip
./scripts/issue-certificate.sh
docker compose up -d
docker compose ps
docker compose logs --tail=100 flexisip
```

The public Android transport is SIP TLS on `5061/tcp`. STUN uses `3478/udp`,
and relayed RTP/RTCP uses `10000-10199/udp`. Plain SIP on `5060/tcp` is bound
to loopback only; a future Asterisk trunk should use a private WireGuard
transport rather than opening that port to the Internet.

`issue-certificate.sh` uses the ACME challenge directory already served by the
host's Nginx Proxy Manager, so no web proxy downtime is required. Install the
project-owned host integrations once after copying the project to the server:

```bash
ln -s /opt/docker/coolnik-sip/systemd/coolnik-sip-firewall.service \
  /etc/systemd/system/coolnik-sip-firewall.service
ln -s /opt/docker/coolnik-sip/systemd/coolnik-sip-cert-renew.service \
  /etc/systemd/system/coolnik-sip-cert-renew.service
ln -s /opt/docker/coolnik-sip/systemd/coolnik-sip-cert-renew.timer \
  /etc/systemd/system/coolnik-sip-cert-renew.timer
ln -s /opt/docker/coolnik-sip/logrotate/coolnik-sip \
  /etc/logrotate.d/coolnik-sip
systemctl daemon-reload
systemctl enable --now coolnik-sip-firewall.service coolnik-sip-cert-renew.timer
```

The firewall service exposes only encrypted SIP and the required media ports.
The renewal timer checks the certificate twice per day and restarts Flexisip
only after Certbot has actually renewed it.
