#!/usr/bin/env bash

# http://stackoverflow.com/questions/15807845/list-files-and-show-them-in-a-menu-with-bash
# Select file
# Usage:
# result = $(selectFile $DIRECTORY)
# echo "result: "$(basename $result)
selectFile ()
{
prompt="Select target kernel version:"
options=( $(find "$1" -maxdepth 1 -print0 | xargs -0) )

PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do
  if (( REPLY == 1 + ${#options[@]} )) ; then
    exit

  elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
    echo "$opt"
    break

  else
    echo "Invalid option. Try another one."
  fi
done
}
KERNEL_VER=($(ls /lib/modules))
if [ ! "${#KERNEL_VER[*]}" -eq 1 ];
then
  result=$(selectFile /lib/modules)
  KERNEL_VER=($(basename $result))
fi
INITRAMFS=/tmp/initramfs-"${KERNEL_VER[0]}".img
dracut -f "$INITRAMFS" "${KERNEL_VER[0]}"
chmod 644 "$INITRAMFS"
exit 0

