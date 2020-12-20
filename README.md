# proxmox-backup-client
CentOS 7 cookbook for build Client for Proxmox Backup Server. the client is written in the Rust programming language.

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# install depends
yum install systemd-devel clang-devel libzstd-devel libacl-devel pam-devel fuse3-devel libuuid-devel
yum groupinstall 'Development Tools'
yum install git

# clone proxmox-backup-client cookbook
git clone https://github.com/sg4r/proxmox-backup-client.git
cd proxmox-backup-client.git

# build
bash ./pbs.build.sh

# check
./target/release/proxmox-backup-client version
client version: 1.0.6

# install binaries

# make clean

