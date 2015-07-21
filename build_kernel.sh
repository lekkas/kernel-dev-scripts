#!/bin/bash

CHROOT=/mnt/root-img
set -o errexit

CORES=$(grep -c ^processor /proc/cpuinfo)

pushd ~/linux

make mrproper
make defconfig
# Required for systemd
scripts/config --enable fhandle

make -j$((CORES + 1))

# Now configure our kerndev environment

sudo umount "$CHROOT" || true
sudo mount -o loop /home/kostas/kerndev/rootfs.img "$CHROOT"
trap "sudo umount $CHROOT" EXIT

sudo make headers_install INSTALL_HDR_PATH="$CHROOT"/usr/
sudo make modules_install INSTALL_MOD_PATH="$CHROOT"/

# Now build a new initrd using our environment.
sudo yum --installroot="$CHROOT" install -y dracut

sudo chroot "$CHROOT"
# Sanity Check - TODO
if [ $(ls /lib/modules | wc -l) -eq 1 ];
  echo "more than 1 kernels are present"
fi

dracut /boot/initramfs.img "TODO KERNEL VERSION"
popd

