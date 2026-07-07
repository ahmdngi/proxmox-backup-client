# Proxmox Backup Client 3.3.3 — Build Guide

This repository contains the patched `Cargo.toml` and step-by-step instructions to build **Proxmox Backup Client 3.3.3** from source on RHEL 8/9 and Rocky Linux.

## Files

| File | Description |
|------|-------------|
| `Cargo.toml.original` | Original Proxmox Backup Cargo.toml (v3.3.4) |
| `Cargo.toml.updated` | Modified Cargo.toml targeting v3.3.3 with local path overrides and h2 downgrade |
| `cargo.patch` | Unified diff between original and updated Cargo.toml |

## Build Steps

### 1. Install Rust and build dependencies

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup update

dnf update
dnf groupinstall 'Development Tools'
dnf install git systemd-devel clang-devel libzstd-devel \
  libacl-devel pam-devel fuse3-devel libuuid-devel openssl-devel
```

### 2. Clone required repos

```bash
git clone git://git.proxmox.com/git/proxmox-backup.git
git clone git://git.proxmox.com/git/proxmox.git
git clone git://git.proxmox.com/git/proxmox-fuse.git
git clone git://git.proxmox.com/git/pathpatterns.git
git clone git://git.proxmox.com/git/pxar.git
```

### 3. Apply the Cargo.toml patch

```bash
patch -p0 < cargo.patch
rm -rf proxmox-backup/.cargo
```

### 4. Fix FUSE `noflush` error

If you encounter:

```
src/glue.c:22:16: error: 'struct fuse_file_info' has no member named 'noflush'
```

Edit `proxmox-fuse/src/glue.c` and remove the line containing `MAKE_ACCESSORS(noflush)`.

### 5. Replace `h2::legacy` references

In these three files:

- `proxmox-backup/pbs-client/src/backup_writer.rs`
- `proxmox-backup/pbs-client/src/http_client.rs`
- `proxmox-backup/pbs-client/src/pipe_to_stream.rs`

Run:

```bash
sed -i 's/h2::legacy/h2/g' proxmox-backup/pbs-client/src/{backup_writer,http_client,pipe_to_stream}.rs
```

**Why?** The upstream v3.3.4 uses `h2` v0.4 with the `legacy` feature. v3.3.3 uses `h2` v0.3 which exposes types directly under `h2::` instead of `h2::legacy::`.

### 6. Build

```bash
cd proxmox-backup
cargo fetch --target x86_64-unknown-linux-gnu
cargo build --release \
  --package proxmox-backup-client --bin proxmox-backup-client \
  --package pxar-bin --bin pxar
```

### 7. Build RPM

```bash
cargo install cargo-generate-rpm
cargo generate-rpm
```

Verify:

```bash
rpm -qip proxmox-backup-3.3.3-1.x86_64.rpm
```

### 8. Install

```bash
dnf install proxmox-backup/target/generate-rpm/proxmox-backup-3.3.3-1.x86_64.rpm
```

Verify:

```bash
proxmox-backup-client version
# client version: 3.3.3
```

## Tested On

| OS | Kernel | Date |
|----|--------|------|
| Rocky Linux 8.10 (Green Obsidian) | 4.18.0-553.40.1.el8_10.x86_64 | 2025-03-25 |
| Rocky Linux 9.5 (Blue Onyx) | 5.14.0-427.22.1.el9_4.x86_64 | 2025-03-25 |

## Acknowledgments

This work is based on the efforts of:

- [sg4r](https://github.com/sg4r) — [sg4r/proxmox-backup-client](https://github.com/sg4r/proxmox-backup-client)
- [TomGem](https://github.com/TomGem) — [TomGem/proxmox-backup-client](https://github.com/TomGem/proxmox-backup-client)
