#!/bin/bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

# qemu-kvm is installed under /usr/libexec
# in CentOS 7
export PATH=$PATH:/usr/libexec

qemu-kvm -enable-kvm -nographic \
  -kernel "$COMPILED_KERNEL"
  -initrd ~/kerndev/initramfs-4.2.0-rc3+.img \
  -hda "$ROOTFS_IMG" \
  -m 1024M -cpu host -smp 4 \
  -append "root=/dev/sda rw console=ttyS0"
