#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
NAMESERVER="192.168.128.200"
# URL for the apt-cacher-ng proxy. Change the IP and port if needed.
APT_PROXY_URL="http://apt-proxy.lan"
# --- End Configuration ---

replace_nameserver() {
    printf 'nameserver %s\n' "$NAMESERVER"
}

setup_apt_proxy() {
    # Create a configuration file for APT to use the proxy
    # This is the correct method for apt-cacher-ng
    printf 'Acquire::http::Proxy "%s";\n' "$APT_PROXY_URL" > /etc/apt/apt.conf.d/02proxy
    echo "APT proxy configured to use ${APT_PROXY_URL}"
}

if [ "$(id -u)" -eq 0 ]; then
    replace_nameserver > /etc/resolv.conf
    setup_apt_proxy
else
    replace_nameserver | sudo tee /etc/resolv.conf >/dev/null
    sudo bash -c "$(declare -f setup_apt_proxy); APT_PROXY_URL='${APT_PROXY_URL}'; setup_apt_proxy"
fi
