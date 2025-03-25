# Steps to Build Proxmox Backup Client 3.3.3

# 1. Install rust and dev tools

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup update

dnf update
dnf groupinstall 'Development Tools'
dnf install git systemd-devel clang-devel libzstd-devel libacl-devel pam-devel fuse3-devel libuuid-devel openssl-devel
```

# 2. Clone required git repos
```bash
git clone git://git.proxmox.com/git/proxmox-backup.git
git clone git://git.proxmox.com/git/proxmox.git
git clone git://git.proxmox.com/git/proxmox-fuse.git
git clone git://git.proxmox.com/git/pathpatterns.git
git clone git://git.proxmox.com/git/pxar.git
```


## 3. Update Cargo.toml

```bash
patch -p0 < cargo.patch
rm -rf proxmox-backup/.cargo
```

## 4. Fix FUSE `noflush` Error

**Error:**
cargo:warning=src/glue.c: In function 'glue_set_ffi_noflush':
cargo:warning=src/glue.c:22:16: error: 'struct fuse_file_info' has no member named 'noflush'; did you mean 'flush'?

**Solution:**
1. Edit `proxmox-fuse/src/glue.c`
2. Remove the last line containing `MAKE_ACCESSORS(noflush)`

## 5. Replace "h2::legacy" with "h2"

**Files to modify:**
- `proxmox-backup/pbs-client/src/backup_writer.rs`
- `proxmox-backup/pbs-client/src/http_client.rs`
- `proxmox-backup/pbs-client/src/pipe_to_stream.rs`

**Command:**
```bash
vim -c '%s/h2::legacy/h2/g' -c 'wq' [files-to-modify]
```


## Reason why h2 was downgraded to v0.3 in Cargo.toml

**Error:**
Compiling pbs-fuse-loop v0.1.0 (/home/backup/client-prox/proxmox-backup-client/proxmox-backup/pbs-fuse-loop)
error[E0308]: mismatched types
    --> pbs-client/src/http_client.rs:975:38
     |
975  |             H2Client::h2api_response(resp).await?; // raise error
     |             ------------------------ ^^^^ expected `Response<RecvStream>`, found a different `Response<RecvStream>`
     |             |
     |             arguments to this function are incorrect
     |
note: two different versions of crate `http` are being used; two types coming from two different versions of the same crate are different types even if they look the same

**Solution:**
Update Cargo.toml to use h2 version 0.3 instead of 0.4:     
`h2 = { version = "0.3", features = [ "stream" ] }`



# 6. Building Proxmox Backup Client

```bash
cd proxmox-backup
cargo fetch --target x86_64-unknown-linux-gnu
cargo build --release --package proxmox-backup-client --bin proxmox-backup-client --package pxar-bin --bin pxar
```

# 7. Build RPM  

```bash
cargo install cargo-generate-rpm
cargo generate-rpm
```


# 8. Check Successful Build
```
root# rpm -qip proxmox-backup-3.3.3-1.x86_64.rpm
Name        : proxmox-backup
Epoch       : 0
Version     : 3.3.3
Release     : 1
Architecture: x86_64
Install Date: (not installed)
Group       : Unspecified
Size        : 22563736
License     : AGPL-3
Signature   : (none)
Source RPM  : (none)
Build Date  : Tue Mar 25 16:36:18 2025
Build Host  : (none)
URL         : https://www.proxmox.com
Summary     : Proxmox Backup
Description :
Proxmox Backup
```

# 9. Package Installation

```bash
dnf install proxmox-backup/target/generate-rpm/proxmox-backup-3.3.3-1.x86_64.rpm"
```


# Notes
- original and modified Cargo.toml are available for reference
- This guide can work for RHEL 8 and RHEL 9
    last tested:
    - at 2025-03-25
    - on Rocky Linux 8.10 (Green Obsidian)
    - and Rocky Linux 9.5 (Blue Onyx)
    - with proxmox-backup-client 3.3.3-1



## Thanks
This work was based on the efforts of these awesome people
- [sg4r](https://github.com/sg4r), REPO [sg4r/proxmox-backup-client](https://github.com/sg4r/proxmox-backup-client)
-  [TomGem](https://github.com/TomGem), REPO  [TomGem/proxmox-backup-client](https://github.com/TomGem/proxmox-backup-client)