#!/bin/bash

qemu-kvm -enable-kvm -nographic \
  -kernel ~/linux.git/arch/x86_64/boot/bzImage \
  -initrd ~/kerndev/initramfs-4.2.0-rc3+.img \
  -hda ~/kerndev/rootfs.img \
  -m 1024M -cpu host -smp 4 \
  -append "root=/dev/sda rw console=ttyS0"
