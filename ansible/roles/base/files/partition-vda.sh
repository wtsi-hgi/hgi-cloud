#!/bin/bash -e

# Uses awk to parse the machine-readable output of parted to figure out the end of the root partition
ROOT_END="$(parted /dev/vda --script print --machine | awk 'BEGIN { FS=":" } $1~/^1$/ {print $3}')"
# Creates a primary partition stating at the end of the root partition
parted --scritp /dev/vda -- mkpart primary linux-swap "${ROOT_END}" -1s
# Tell Linux that the partition table changed
partprobe /dev/vda
# Make a swap filesystem out of the newly created partition
mkswap /dev/vda2
# Configure /etc/fstab to use the swap partition at boot
echo "/dev/vda2   swap   swap defaults 0 0" >> /etc/fstab
# Enable the swap partition
swapon -a
# SIZE=$(swapon -s | grep /dev/vda2 | awk '{printf ("%d", $3*75/100/(1024*1024) ); }')
# echo "tmpfs                 /tmp    tmpfs   defaults,noatime,mode=1777,nosuid,size=${SIZE}G 0 0" >> /etc/fstab

