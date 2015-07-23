#!/usr/bin/env bash

KERNEL_VER=($(ls /lib/modules))
if [ ! "${#KERNEL_VER[*]}" -eq 1 ];
then
  error "More than 1 kernels are present: "${KERNEL_VER[*]}
  error "You will need to create initramfs manually."
  exit 1
else
  local INITRAMFS=/tmp/initramfs-${KERNEL_VER[0]}
  dracut -f "$INITRAMFS" "${KERNEL_VER[0]}"
  exit 0
fi

