#vars!/usr/bin/env bash

source ./deps/kerndev-vars.sh
source ./deps/kerndev-functions.sh

if [ $EUID != 0 ];
then
  fatal "This script should be run as root."
fi

# Create dev user
if [ ! -d "/home/$USER" ];
then
  echo "## Creating user $USER ##"
  useradd -m "$USER" -G wheel
fi

# Create working directories
mkdir -p "$CHROOT"
runAs "$USER" "mkdir -p "$KERNDEV_HOME""

# List of packets to install on host Centos 7 kernel development machine
yum install -y bc git make gcc ctags make gcc
yum install -y screen vim wget net-tools mutt cyrus-sasl cyrus-sasl-plain
yum install -y qemu-kvm qemu-kvm-tools libvirt-daemon-kvm

# Create misc config and rc files for user dev environment
runAs "$USER" "$(pwd)/createConfigFiles.sh"

# Clone linux git repository
echo "## Cloning linux git repository into $LINUX_SOURCE_HOME"
runAs "$USER" "git clone "$LINUX_GIT" "$LINUX_SOURCE_HOME""

# Create Centos 7 root image
if [ -a "$ROOTFS_IMG" ];
then
  echo "## $ROOTFS_IMG already exists. Backing it up. ##"
  mv $ROOTFS_IMG $ROOTFS_IMG.$(date +%s)
fi

runAs "$USER" "qemu-img create -f raw "$ROOTFS_IMG $ROOTFS_SIZE""
runAs "$USER" "mkfs.ext4 "$ROOTFS_IMG""
mount -o loop "$ROOTFS_IMG" "$CHROOT"

# Initialize RPM database
mkdir -p "$CHROOT/var/lib/rpm"
rpm --root="$CHROOT" --rebuilddb

# Download centos-release
push /tmp
wget "$CENTOS7_URL"
sudo rpm --root="$CHROOT" --nodeps -i "$CENTOS7_RPM"
# Cleanup
rm /tmp/"$CENTOS7_RPM"
pop

# Install CentOS on the root image
yum --installroot="$CHROOT" update
yum --installroot="$CHROOT" install -y yum
# Install dracut to create initramfs image
yum --installroot="$CHROOT" install -y dracut

# Make root passwordless for convenience.
sed -i '/^root/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

# TODO : Add user into VM root image ?

# Cleanup and exit
unmount "$CHROOT"

echo "## Done! ##"
