#!/bin/bash -e

# Use awk to parse the machine-readable output of parted to figure out the end of the root partition
ROOT_END="$(parted /dev/vda --script print --machine | awk 'BEGIN { FS=":" } $1~/^1$/ {print $3}')"

# Creates a primary partition stating at the end of the root partition
parted --script /dev/vda -- mkpart primary linux-swap "${ROOT_END}" 100%

# Tell Linux that the partition table changed
partprobe /dev/vda
