#!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

CORES=$(grep -c ^processor /proc/cpuinfo)

push ~/linux.git
echo "## Configuring kernel ##"
make mrproper
make defconfig

# Required for systemd
scripts/config --enable fhandle

echo "## Compiling kernel ##"
make -j$((CORES + 1))

# Mount VM root partition, install kernel headers and modules
echo "## Installing kernel headers and modules into VM root fs ##"
sudo unmount "$CHROOT"
sudo mount -o loop "$ROOTFS_IMG" "$CHROOT"

sudo make headers_install INSTALL_HDR_PATH="$CHROOT"/usr/
sudo make modules_install INSTALL_MOD_PATH="$CHROOT"/

echo "## Creating initramfs ##"
sudo chroot "$CHROOT" ./initramfs_create_chroot.sh
if [ "$?" -eq 0 ];
then
  mv "$CHROOT"/tmp/initramfs-* "$KERNDEV_HOME"
fi

sudo unmount "$CHROOT"

pop

echo "Done!"
