#!/usr/bin/env bash

CHROOT=/mnt/root-img
CORES=$(grep -c ^processor /proc/cpuinfo)
USER=kostas
HOMEDIR=/home/"$USER"
KERNDEV_HOME="$HOMEDIR"/kerndev
LINUX_SOURCE_HOME="$KERNDEV_HOME"/linux.git
ROOTFS_IMG="$KERNDEV_HOME"/rootfs.img
ROOTFS_SIZE=30G

LINUX_GIT="git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
CENTOS7_RPM="centos-release-7-1.1503.el7.centos.2.8.x86_64.rpm"
CENTOS7_URL="http://mirror.centos.org/centos/7/os/x86_64/Packages/$CENTOS7_RPM"


COMPILED_KERNEL="$LINUX_SOURCE_HOME"/arch/x86_64/boot/bzImage
