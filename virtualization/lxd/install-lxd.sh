#!/usr/bin/env bash
#
# Install and configure LXD on Ubuntu using the ZFS storage backend.
#
# Run as your normal user (not root) - the script uses sudo where it needs
# elevated privileges. It installs LXD + ZFS tools, initializes LXD, adds the
# current user to the "lxd" group, exposes the LXD API over the network, and
# creates a TLS identity for the LXD UI.
#
set -euo pipefail

# Install LXD from the snap store (the recommended install method on Ubuntu).
sudo snap install lxd

# Install the ZFS utilities that LXD will use for its storage pool.
sudo apt update
sudo apt install -y zfsutils-linux
sudo modprobe zfs
ls -l /dev/zfs        # should exist now

# Initialize LXD interactively (creates the default ZFS storage pool, network, etc.).
sudo lxd init         # run it again

# Add the current user to the "lxd" group so lxc/lxd commands work without sudo.
# The check makes re-running the script idempotent.
getent group lxd | grep -qwF "$USER" || sudo usermod -aG lxd "$USER"

# Apply the new group membership to the current shell, then verify the CLI works.
newgrp lxd
lxc version

# Bind the LXD API to all interfaces on port 8443 (needed for remote access / UI).
lxc config set core.https_address :8443
hostname -I                                # shows your server's IP

# Create a TLS client identity for the LXD UI and grant it admin rights.
lxc auth identity create tls/lxd-ui --group admins
