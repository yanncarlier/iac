

#!/bin/bash
# =============================================================================
# 
# 
# ── 4. UFW — allow LXD bridge traffic (required for VM DHCP + internet) ───────
# 
# =============================================================================

set -euo pipefail

echo "[*] Configuring UFW bridge rules..."
# ufw allow in on lxdbr0        2>/dev/null || true
# ufw route allow in on lxdbr0  2>/dev/null || true
# ufw route allow out on lxdbr0 2>/dev/null || true
# lxc network set lxdbr0 ipv4.nat true


ufw allow in on lxdbr0 from 0.0.0.0/0        2>/dev/null || true
ufw route allow in on lxdbr0 from 0.0.0.0/0  2>/dev/null || true
ufw route allow out on lxdbr0 to 0.0.0.0/0   2>/dev/null || true
lxc network set lxdbr0 ipv4.nat true



BRIDGE="lxdbr0"

echo "[*] Configuring UFW bridge rules for ${BRIDGE}..."

# Insert at position 1 so these rules are evaluated BEFORE any existing deny
# rules (UFW evaluates rules top to bottom; the first match wins).
# No "from <addr>" so both IPv4 and IPv6 are covered.

# Host-bound traffic from the bridge (DHCP, DNS).
sudo ufw insert 1 allow in on "${BRIDGE}"

# Forwarded traffic through the host (container <-> internet).
sudo ufw route insert 1 allow in on "${BRIDGE}"
sudo ufw route insert 1 allow out on "${BRIDGE}"

# Make sure LXD NATs container traffic to the outside world.
lxc network set "${BRIDGE}" ipv4.nat true
lxc network set "${BRIDGE}" ipv6.nat true

# Apply the rules.
sudo ufw reload

echo "[*] Current UFW status:"
sudo ufw status numbered