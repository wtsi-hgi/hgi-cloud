#!/bin/bash -eux

# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M >/dev/null 2>&1 || rm --force /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync ; sync ; sync
