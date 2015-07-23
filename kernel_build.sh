#!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

# We need to pass env variables to sudo shell
alias sudo='sudo -E'

CORES=$(grep -c ^processor /proc/cpuinfo)

push "$LINUX_SOURCE_HOME"

echo "## Configuring kernel ##"
make mrproper
make defconfig

# Required for systemd
scripts/config --enable fhandle

echo "## Compiling kernel ##"
make -j$((CORES + 1))

# Mount VM root partition, install kernel headers and modules
echo "## Installing kernel headers and modules into VM root fs ##"
sudo umount "$CHROOT" &>/dev/null
sudo mount -o loop "$ROOTFS_IMG" "$CHROOT"

sudo make headers_install INSTALL_HDR_PATH="$CHROOT"/usr/
sudo make modules_install INSTALL_MOD_PATH="$CHROOT"/

pop

echo "## Creating initramfs ##"
sudo cp ./initramfs_create_chroot.sh "$CHROOT"/tmp
sudo chroot "$CHROOT" /tmp/initramfs_create_chroot.sh
if [ "$?" -eq 0 ];
then
  mv "$CHROOT"/tmp/initramfs-* "$KERNDEV_HOME"
fi

# Cleanup
sudo umount "$CHROOT" &>/dev/null
unalias sudo

echo "Done!"
