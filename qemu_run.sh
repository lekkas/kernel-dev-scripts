#!/bin/bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

# qemu-kvm is installed under /usr/libexec
# in CentOS 7
export PATH=$PATH:/usr/libexec

qemu-kvm -enable-kvm -nographic \
  -kernel "$KERNDEV_HOME/boot/bzImage" \
  -initrd "$KERNDEV_HOME/boot/initramfs.img" \
  -hda "$ROOTFS_IMG" \
  -m 1024M -cpu host -smp 4 \
  -append "root=/dev/sda rw console=ttyS0"
