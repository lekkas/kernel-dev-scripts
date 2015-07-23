#!/usr/bin/env bash

KERNEL_VER=($(ls /lib/modules))
if [ ! "${#KERNEL_VER[*]}" -eq 1 ];
  error "More than 1 kernels are present: "${KERNEL_VER[*]}
  error "You will need to create initramfs manually."
  return 1;
else
  INITRAMFS=/tmp/initramfs-${KERNEL_VER[0]}
  dracut "$INITRAMFS" "${KERNEL_VER[0]}"
  return 0
fi

