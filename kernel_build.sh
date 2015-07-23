#!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

CORES=$(grep -c ^processor /proc/cpuinfo)

pushd ~/linux.git
make mrproper
make defconfig

# Required for systemd
scripts/config --enable fhandle

make -j$((CORES + 1))

# Mount VM root partition, install kernel headers and modules
sudo unmount "$CHROOT"
sudo mount -o loop "$ROOTFS_IMG" "$CHROOT"

sudo make headers_install INSTALL_HDR_PATH="$CHROOT"/usr/
sudo make modules_install INSTALL_MOD_PATH="$CHROOT"/

sudo unmount $CHROOT
popd
