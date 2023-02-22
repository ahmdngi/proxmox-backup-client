#!/bin/bash
# 
# build proxmox-backup-client for RHEL 8 and RHEL 9
#  last tested:
#   - at 2023-02-22
#   - on Red Hat Enterprise Linux release 8.7 (Ootpa)
#   - and Red Hat Enterprise Linux release 9.0 (Plow)
#   - with proxmox-backup-client 2.3.3
# 

# requirements
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#source $HOME/.cargo/env

#dnf update
#dnf groupinstall 'Development Tools'
#dnf install git systemd-devel clang-devel libzstd-devel libacl-devel pam-devel fuse3-devel libuuid-devel openssl-devel

#git clone https://github.com/tomgem/proxmox-backup-client.git
#cd proxmox-backup-client
#bash build.sh

echo "cloning Proxmox repositories ..."
git clone git://git.proxmox.com/git/proxmox-backup.git
git clone git://git.proxmox.com/git/proxmox.git
git clone git://git.proxmox.com/git/proxmox-fuse.git
git clone git://git.proxmox.com/git/pxar.git
echo "done"

echo "patching Cargo.toml ..."
patch -p0 < cargo.patch
rm -f proxmox-backup/.cargo/config
rmdir proxmox-backup/.cargo
echo "done"

echo "building proxmox-backup-client ..."
cd proxmox-backup
cargo fetch --target x86_64-unknown-linux-gnu
cargo build --release --package proxmox-backup-client --bin proxmox-backup-client --package pxar-bin --bin pxar

if [[ $? == 0 ]]; then
    echo "build successful"
    ./target/release/proxmox-backup-client version
else
    echo "build failed"
    exit 1
fi

echo "build rpm ..."
cargo install cargo-generate-rpm
cargo generate-rpm

if [[ $? == 0 ]]; then
    echo "rpm build successful"
    rpm -qip target/generate-rpm/proxmox-backup-2.3.3-1.x86_64.rpm
    rpm -qlp target/generate-rpm/proxmox-backup-2.3.3-1.x86_64.rpm
else
    echo "rpm build failed"
    exit 1
fi

echo ""
echo "The proxmox-backup rpm can be found in the folder proxmox-backup/target/generate-rpm"
echo "Install it with dnf:"
echo "dnf install proxmox-backup/target/generate-rpm/proxmox-backup-2.3.3-1.x86_64.rpm"
echo ""
