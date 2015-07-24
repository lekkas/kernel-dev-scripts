#!/usr/bin/env bash

KERNEL_VER=($(ls /lib/modules))
if [ ! "${#KERNEL_VER[*]}" -eq 1 ];
then
  error "More than 1 kernels are present: "${KERNEL_VER[*]}
  error "You will need to create initramfs manually."
  exit 1
else
  INITRAMFS=/tmp/initramfs-"${KERNEL_VER[0]}".img
  dracut -f "$INITRAMFS" "${KERNEL_VER[0]}"
  chmod 644 "$INITRAMFS"
  exit 0
fi

