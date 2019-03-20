#!/bin/bash -eux

if [ -d /opt/sanger.ac.uk/testinfra ] ; then
  for testinfra in $(find /opt/sanger.ac.uk/testinfra -name \*.py) ; do
    python3 "${testinfra}"
  done
fi
