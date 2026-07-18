#!/bin/sh
set -eu

iptables_bin=/usr/sbin/iptables
chain=CODEX-INPUT

add_rule() {
  if ! "$iptables_bin" -C "$chain" "$@" -j ACCEPT 2>/dev/null; then
    "$iptables_bin" -I "$chain" 1 "$@" -j ACCEPT
  fi
}

# Only encrypted SIP is public. Plain SIP remains reachable from loopback and
# trusted Docker bridges for local integration and registration tests.
add_rule -p tcp --dport 5061
add_rule -p udp --dport 3478
add_rule -p udp --dport 10000:10199
