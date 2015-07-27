#!/usr/bin/env bash

set -e

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

# We need to pass env variables to sudo shell
alias sudo='sudo -E'

CORES=$(grep -c ^processor /proc/cpuinfo)

if [ -z $KERNELDIR ];
then
  echo "Please set KERNELDIR variable to specify the kernel source directory"
  exit 1;
fi

push $KERNELDIR

echo "## Configuring kernel ##"
make mrproper
make defconfig

# Required for systemd
scripts/config --enable fhandle
# Required or system hangs on boot
scripts/config --enable CONFIG_DEVTMPFS_MOUNT

# Set EXTRAVERSION
set -i "/^EXTRAVERSION/ { s/$/$EXTRAVERSION/ }" $KERNELDIR/Makefile

echo "## Compiling kernel ##"
make -j$((CORES + 1))

# Mount VM root partition, install kernel headers and modules
echo "## Installing kernel headers and modules into VM root fs ##"
sudo umount "$CHROOT" &>/dev/null
sudo mount -o loop "$ROOTFS_IMG" "$CHROOT"

sudo make headers_install INSTALL_HDR_PATH="$CHROOT"/usr/
sudo make modules_install INSTALL_MOD_PATH="$CHROOT"/

echo "## Copying kernel image into $KERNEL_BOOT ##"
cp arch/"$uname -i"/boot/bzImage $KERNEL_BOOT
pop

echo "## Creating initramfs ##"
sudo cp ./initramfs_create_chroot.sh "$CHROOT"/tmp
sudo chroot "$CHROOT" /tmp/initramfs_create_chroot.sh

if [ "$?" -eq 0 ];
then
  echo "## Moving initramfs into $KERNEL_BOOT ##"
  sudo mv "$CHROOT"/tmp/initramfs-* "$KERNEL_BOOT"
fi

# Cleanup
sudo rm "$CHROOT"/tmp/initramfs_create_chroot.sh
sudo umount "$CHROOT"
unalias sudo

echo "Done!"
