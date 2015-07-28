#!/usr/bin/env bash

KERNEL_VER=($(ls /lib/modules))
if [ ! "${#KERNEL_VER[*]}" -eq 1 ];
then
  result=$(selectFile $1)
  KERNEL_VER=($(basename $result))
else
  INITRAMFS=/tmp/initramfs-"${KERNEL_VER[0]}".img
  dracut -f "$INITRAMFS" "${KERNEL_VER[0]}"
  chmod 644 "$INITRAMFS"
  exit 0
fi

