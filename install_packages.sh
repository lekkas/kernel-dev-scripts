set -e

CHROOT=/mnt/root-img

# Miscellaneous

yum install -y bc git make gcc ctags make gcc
yum install -y screen vim wget
yum install -y qemu-kvm qemu-kvm-tools libvirt-daemon-kvm

# Create working directories
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ~/linux.git
mkdir ~/kerndev
sudo mkdir "$CHROOT"


# Create Centos 7 root image
cd ~/kerndev
qemu-img create -f raw rootfs.img 30G
mkfs.ext4 rootfs.img
sudo mount -o loop rootfs.img "$CHROOT"

# Initialize RPM database
sudo mkdir -p "$CHROOT/var/lib/rpm"
sudo rpm --root="$CHROOT" --rebuilddb
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/centos-release-7-1.1503.el7.centos.2.8.x86_64.rpm
sudo rpm --root="$CHROOT" --nodeps -i centos-release-7-1.1503.el7.centos.2.8.x86_64.rpm
rm centos-release-7-1.1503.el7.centos.2.8.x86_64.rpm

# Install CentOS on the root image
sudo yum --installroot="$CHROOT" update
sudo yum --installroot="$CHROOT" install -y yum

# Make root passwordless for convenience.
sudo sed -i '/^root/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

# Add user kostas
useradd -m kostas -G wheel
exit
sudo sed -i '/^kostas/ { s/:x:/::/ }' "$CHROOT"/etc/passwd

# Cleanup and exit
sudo umount "$CHROOT"
export PATH=$PATH:/usr/libexec


