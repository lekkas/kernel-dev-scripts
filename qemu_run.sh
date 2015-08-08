#!/bin/bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

# qemu-kvm is installed under /usr/libexec
# in CentOS 7
export PATH=$PATH:/usr/libexec

sudo /usr/libexec/qemu-kvm -enable-kvm -nographic \
  -kernel "$KERNDEV_HOME/boot/bzImage" \
  -initrd "$KERNDEV_HOME/boot/initramfs.img" \
  -hda "$ROOTFS_IMG" \
  -m 1024M -cpu host -smp 4 \
  -append "root=/dev/sda rw console=ttyS0" \
# Add usb host
# -usb -device usb-host,id=hostkbd,hostbus=3
  -monitor telnet:127.0.0.1:1234,server,nowait \
  -usb

#  -usb -device usb-host,id=hostkbd,hostbus=3
#  -usb -device usb-kbd,id=hostkbd,hostbus=3,hostaddr=5 \

# In Qemu monitor (telnet localhost 1234):
  # Detach keyboard
  # device_del hostkbd

  # Re attach keyboard
  # device_add usb-host,hostbus=3,hostaddr=5,id=hostkbd
