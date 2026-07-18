FROM debian:12-slim

ARG FLEXISIP_PACKAGE_VERSION=2.6.0-1

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gnupg wget; \
    wget -q https://download.linphone.org/snapshots/debian/keyring.gpg -O /tmp/belledonne-keyring.gpg; \
    gpg --dearmor -o /usr/share/keyrings/belledonne-archive-keyring.gpg /tmp/belledonne-keyring.gpg; \
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://download.linphone.org/snapshots/debian/' \
      'Suites: bookworm' \
      'Architectures: amd64' \
      'Components: stable' \
      'Signed-By: /usr/share/keyrings/belledonne-archive-keyring.gpg' \
      > /etc/apt/sources.list.d/belledonne.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends "bc-flexisip=${FLEXISIP_PACKAGE_VERSION}"; \
    apt-mark hold bc-flexisip; \
    apt-get purge -y --auto-remove gnupg wget; \
    rm -rf /var/lib/apt/lists/* /tmp/belledonne-keyring.gpg

EXPOSE 5060/tcp 5061/tcp 3478/udp
EXPOSE 10000-10199/udp

ENTRYPOINT ["/opt/belledonne-communications/bin/flexisip"]
CMD ["--server", "proxy"]
