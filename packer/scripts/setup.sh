#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive

# Install Ansible repository.
apt-get --assume-yes --quiet update && apt-get --assume-yes --quiet upgrade
apt-get --assume-yes --quiet install software-properties-common
apt-add-repository --yes ppa:ansible/ansible

# Install Ansible.
apt-get --assume-yes --quiet update
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --quiet install ansible python-apt
mkdir --parents /opt/sanger.ac.uk/ansible/{log,facts.d}
chown --recursive ubuntu:ubuntu /opt/sanger.ac.uk

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
