#!/usr/bin/env bash

set -e

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

if [ $EUID != 0 ];
then
  fatal "This script should be run as root."
fi

##################################
# Development Environment Setup  #
##################################

echo "## Installing packages needed for kernel development into host system ##"
yum install -y bc git git-email make gcc ctags make gcc kernel-devel
yum install -y screen vim wget net-tools mutt cyrus-sasl cyrus-sasl-plain
yum install -y qemu-kvm qemu-kvm-tools libvirt-daemon-kvm

yum install -y rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto
yum install -y audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel
yum install -y ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel

echo "## Creating development environment for user "$USER" ##"
if [ ! -d "/home/$USER" ];
then
  echo "## Creating user $USER ##"
  useradd -m "$USER" -G wheel
fi

mkdir -p "$CHROOT"
runAs "$USER" "mkdir -p "$KERNDEV_HOME""
runAs "$USER" "mkdir -p "$KERNEL_SOURCE""
runAs "$USER" "mkdir -p "$KERNEL_BOOT""

echo "## Adding .rc files into /home/"$USER" ##"
runAs "$USER" "./createConfigFiles.sh"

echo "## Cloning linux git repository into $KERNEL_SOURCE/linux.git"
runAs "$USER" "git clone "$LINUX_GIT" "$KERNEL_SOURCE"/linux.git" || true

if [ ! -d $CENTOS7_KERNEL_DIR ];
then
  # Needed for kernel unpacking
  runAs "$USER" "mkdir -p $KERNDEV_HOME/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}"
  runAs "$USER" "echo \"%_topdir $KERNDEV_HOME/rpmbuild\" > ~/.rpmmacros"

  echo "## Downloading official Centos kernel sources into $KERNDEV_HOME"
  runAs "$USER" "wget "$CENTOS7_KERNEL_URL" -P $KERNDEV_HOME"
  runAs "$USER" "rpm -i $KERNDEV_HOME/$CENTOS7_KERNEL_RPM"

  push $KERNDEV_HOME/rpmbuild/SOURCES
  runAs $USER "xz -d linux-$CENTOS7_KERNEL_VER.tar.xz"
  runAs $USER "tar xf linux-$CENTOS7_KERNEL_VER.tar"
  runAs $USER "mv linux-$CENTOS7_KERNEL_VER $KERNEL_SOURCE"
  pop

  # Cleanup
  rm $KERNDEV_HOME/$CENTOS7_KERNEL_RPM
  rm -rf $KERNDEV_HOME/rpmbuild
  rm /home/$USER/.rpmmacros
fi

#######################
# VM Root Image Setup #
#######################

echo "## Creating Centos 7 VM root image"
if [ -a "$ROOTFS_IMG" ];
then
  echo "## $ROOTFS_IMG already exists. ##"
else
  runAs "$USER" "qemu-img create -f raw "$ROOTFS_IMG" "$ROOTFS_SIZE""
  runAs "$USER" "mkfs.ext4 "$ROOTFS_IMG""
  mount -o loop "$ROOTFS_IMG" "$CHROOT"

  # Initialize RPM database for VM root image
  mkdir -p "$CHROOT/var/lib/rpm"
  rpm --root="$CHROOT" --rebuilddb

  # Download centos-release
  push /tmp
  wget "$CENTOS7_URL"
  sudo rpm --root="$CHROOT" --nodeps -i "$CENTOS7_RPM"
  # Cleanup
  rm /tmp/"$CENTOS7_RPM"
  pop

  echo "## Install CentOS base on VM root image ##"
  yum --installroot="$CHROOT" update
  yum --installroot="$CHROOT" install -y yum
  yum --installroot="$CHROOT" install -y dracut
  yum --installroot="$CHROOT" install -y vim
  yum --installroot="$CHROOT" install -y usbutils

  # Make root passwordless for convenience.
  sed -i '/^root/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

  # TODO : Add user into VM root image ?

  # Cleanup and exit
  unmount "$CHROOT"
fi

echo "## Done! ##"
