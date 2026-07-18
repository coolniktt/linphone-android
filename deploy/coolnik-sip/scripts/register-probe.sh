#!/bin/sh
set -eu

# This script runs only inside the disposable registration-test container. It
# reads the SIP password from the read-only secret mount so it never appears in
# Docker arguments or the shell history.
apt-get update -qq
DEBIAN_FRONTEND=noninteractive \
  apt-get install -y -qq --no-install-recommends ca-certificates linphone-cli >/dev/null

umask 077
probe_home=/tmp/linphone-home
mkdir -p "$probe_home/.local/share/linphone"

sip_pass=$(awk '
  $1 == "ulta@sip.coolnik.ru" {
    sub(/^clrtxt:/, "", $2)
    print $2
    exit
  }
' /run/secrets/users.conf)
test -n "$sip_pass"

{
  printf 'register sip:ulta@sip.coolnik.ru sip:sip.coolnik.ru;transport=tls %s\n' "$sip_pass"
  sleep 60
  printf 'proxy remove 0\n'
  sleep 5
  printf 'quit\n'
} | HOME="$probe_home" linphonec -d 5
