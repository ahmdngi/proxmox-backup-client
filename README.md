# proxmox-backup-client

Proxmox Backup Client for Red Hat Enterprise Linux RHEL 8 and RHEL 9

This will also work with Rocky Linux 8, Rocky Linux 9, AlmaLinux 8 and AlmaLinux 9.

Users reported it works on Fedora (at least 36) too.


## Option A - Use the prebuilt binary rpm package

### Binary package

The RPM packages for RHEL 8 and RHEL 9 are available as assets of release [2.4.1](https://github.com/tomgem/proxmox-backup-client/releases/tag/2.4.1).

### Install the binary package

Please note: this rpm does not (yet) have dependencies. Make sure the following packages are installed:

```
dnf install systemd-libs libgcc libzstd libacl fuse3-libs libuuid openssl-libs
```

Now install the rpm:

```
dnf install proxmox-backup-2.4.1-1.x86_64.rpm
```


## Option B - Build the rpm yourself

### Install requirements (needed on build host only)

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

```
dnf update
dnf groupinstall 'Development Tools'
dnf install git systemd-devel clang-devel libzstd-devel libacl-devel pam-devel fuse3-devel libuuid-devel openssl-devel
```

### Clone proxmox-backup-client cookbook

```
git clone https://github.com/tomgem/proxmox-backup-client.git
```

### Build it

```
cd proxmox-backup-client
bash build.sh
```

### Install the rpm

Please note: this rpm does not (yet) have dependencies. Make sure the following packages are installed on a new host:

```
dnf install systemd-libs libgcc libzstd libacl fuse3-libs libuuid openssl-libs
```

Now install proxmox-backup-client:

```
dnf install proxmox-backup/target/generate-rpm/proxmox-backup-2.4.1-1.x86_64.rpm
```

### Test it

```
proxmox-backup-client version
client version: 2.4.1
```

## Thanks

Thanks to [sg4r](https://github.com/sg4r), this is a fork of his work [sg4r/proxmox-backup-client](https://github.com/sg4r/proxmox-backup-client).
