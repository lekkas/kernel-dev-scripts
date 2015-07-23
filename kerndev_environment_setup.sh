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
runAs kostas "qemu-img create -f raw $ROOTFS_IMG $ROOTFS_SIZE"
runAs kostas mkfs.ext4 "$ROOTFS_IMG"
mount -o loop "$ROOTFS_IMG" "$CHROOT"

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

# Install dracut to create initramfs for new kernels
yum --installroot="$CHROOT" install -y dracut

# TODO : Add user?

# Cleanup and exit
unmount "$CHROOT"
