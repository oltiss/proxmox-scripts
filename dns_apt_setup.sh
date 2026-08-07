#!/usr/bin/env bash
set -euo pipefail

NAMESERVER="192.168.128.200"

replace_nameserver() {
    printf 'nameserver %s\n' "$NAMESERVER"
}

if [ "$(id -u)" -eq 0 ]; then
    replace_nameserver > /etc/resolv.conf
else
    replace_nameserver | sudo tee /etc/resolv.conf >/dev/null
fi
