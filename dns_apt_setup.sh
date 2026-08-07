#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
NAMESERVER="192.168.128.200"
APT_SERVER="http://192.168.128.50"
# --- End Configuration ---

replace_nameserver() {
    printf 'nameserver %s\n' "$NAMESERVER"
}

setup_apt_sources() {
    # Get Debian version codename (e.g., bookworm)
    local codename
    codename=$(lsb_release -cs)

    # Setup Debian sources
    cat > /etc/apt/sources.list <<EOF
deb [trusted=yes] ${APT_SERVER}/debian ${codename} main contrib
deb [trusted=yes] ${APT_SERVER}/debian ${codename}-updates main contrib

# security updates
deb [trusted=yes] ${APT_SERVER}/debian-security ${codename}-security main contrib
EOF

    # Conditionally setup Proxmox sources if this is a PVE host
    if command -v pveversion >/dev/null 2>&1; then
        echo "Proxmox VE detected. Setting up PVE repositories."
        cat > /etc/apt/sources.list.d/pve-local.list <<EOF
deb [trusted=yes] ${APT_SERVER}/pve ${codename} pve-no-subscription
EOF
        rm -f /etc/apt/sources.list.d/pve-enterprise.list
    fi
}

if [ "$(id -u)" -eq 0 ]; then
    replace_nameserver > /etc/resolv.conf
    setup_apt_sources
else
    replace_nameserver | sudo tee /etc/resolv.conf >/dev/null
    sudo bash -c "$(declare -f setup_apt_sources); setup_apt_sources"
fi
