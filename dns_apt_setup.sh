#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
NAMESERVER="192.168.128.200"
# URL for the apt-cacher-ng proxy. Change the IP and port if needed.
APT_PROXY_URL="http://apt-proxy.lan:3142" # apt-cacher-ng default port is 3142
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

update_system() {
    echo "Updating package lists..."
    apt-get update
    echo "Upgrading packages..."
    # -y to automatically say yes to prompts
    # --no-install-recommends to avoid installing extra packages
    apt-get upgrade -y --no-install-recommends
    echo "Cleaning up old packages..."
    apt-get autoremove -y
    apt-get clean
    echo "System update complete."
}

# --- Main Logic ---

# Ensure the script is run as root, as it modifies system files.
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use 'sudo'." >&2
  exit 1
fi

replace_nameserver > /etc/resolv.conf
setup_apt_proxy
update_system
