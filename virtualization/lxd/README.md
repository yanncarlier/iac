# Canonical LXD on Ubuntu 24.04 LTS

This README covers the recommended LXD installation method on Ubuntu 24.04 LTS and a small set of common `lxc` operations.

## Install LXD (snap)

```bash
sudo snap install lxd
```

Initialize LXD and accept defaults (or customize as needed):

```bash
sudo apt update
sudo apt install -y zfsutils-linux
sudo modprobe zfs
ls -l /dev/zfs        # should exist now
sudo lxd init         # run it again
```

Allow your user to run `lxc` commands without `sudo`:

```bash
getent group lxd | grep -qwF "$USER" || sudo usermod -aG lxd "$USER"
newgrp lxd
```

```bash
lxc version
```

1. Enable the HTTPS listener

```
lxc config set core.https_address :8443
hostname -I                                # shows your server's IP
```

https://localhost:8443

## Common Operations (Examples)

Launch a container and a VM:

```bash
lxc launch ubuntu:26.04 u2604

lxc launch ubuntu:24.04 u2404
lxc launch ubuntu:24.04 u2404-vm --vm


sudo ufw status verbose
lxc exec u2604 -- resolvectl status
lxc exec u2604 -- ping -c1 1.1.1.1      # works? then only DNS is broken
```

List instances and show details:

```bash
lxc list
lxc info u2404
```

Run commands inside an instance:

```bash
lxc exec u2404 -- apt-get update
lxc exec u2404 -- bash
```

Stop, start, and delete:

```bash
lxc stop u2404
lxc start u2404
lxc delete u2404
```

Snapshots:

```bash
lxc snapshot u2404 pre-change
lxc restore u2404 pre-change
lxc delete u2404/pre-change
```

File copy:

```bash
lxc file push ./local.txt u2404/root/local.txt
lxc file pull u2404/root/local.txt ./local.txt
```

Networking quick check:

```bash
lxc network list
lxc network show lxdbr0
```

Profiles:

```bash
lxc profile list
lxc profile show default
```

## Notes

For most Ubuntu systems, the snap package is the recommended and supported install method for LXD. If you run clusters, consider snap cohort pinning and update management in the official documentation.


ssh -L 4200:127.0.0.1:4200 openfang@{$VMIP}

~/.openfang/bin/openfang start

