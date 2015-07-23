#vars!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

if [ $EUID != 0 ];
then
  fatal "This script should be run as root."
fi

# List of packets to install on host Centos 7 kernel development machine
yum install -y bc git make gcc ctags make gcc
yum install -y screen vim wget net-tools
yum install -y qemu-kvm qemu-kvm-tools libvirt-daemon-kvm

# Create working directories
mkdir "$CHROOT"
runAs kostas "mkdir "$KERNDEV_HOME""
runAs kostas "git clone "$LINUX_GIT" "$LINUX_SOURCE_HOME""

# Create Centos 7 root image
cd ~/kerndev
qemu-img create -f raw rootfs.img 30G
mkfs.ext4 rootfs.img
mount -o loop rootfs.img "$CHROOT"

# Initialize RPM database
mkdir -p "$CHROOT/var/lib/rpm"
rpm --root="$CHROOT" --rebuilddb
wget "$CENTOS7_REL"
sudo rpm --root="$CHROOT" --nodeps -i "$CENTOS7_RPM"

# Cleanup
rm "$CENTOS7_RPM"

# Install CentOS on the root image
yum --installroot="$CHROOT" update
yum --installroot="$CHROOT" install -y yum

# Make root passwordless for convenience.
sed -i '/^root/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

# Add user kostas
# sudo chroot "$CHROOT"
# useradd -m kostas -G wheel
# exit
# sudo sed -i '/^kostas/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

# Create initramfs
yum --installroot="$CHROOT" install -y dracut
chroot "$CHROOT"

# Sanity Check - TODO
if [ $(ls /lib/modules | wc -l) -eq 1 ];
  echo "more than 1 kernels are present"
fi

dracut /boot/initramfs.img "TODO KERNEL VERSION"

# Cleanup and exit
unmount "$CHROOT"
